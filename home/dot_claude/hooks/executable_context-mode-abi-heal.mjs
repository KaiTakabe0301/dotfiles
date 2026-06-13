#!/usr/bin/env node
// context-mode ABI self-heal (SessionStart hook).
//
// mise's `node = "latest"` periodically rolls Node to a new major version,
// changing NODE_MODULE_VERSION (ABI). The context-mode plugin ships a
// better-sqlite3 native binary compiled for one ABI; after a Node major bump
// it no longer matches and dlopen fails (ERR_DLOPEN_FAILED), taking down the
// context-mode MCP runtime.
//
// The plugin's own ensure-deps.mjs does NOT recover on modern Node (>=22.5):
// it skips the dlopen probe and only rebuilds when the binary file is MISSING,
// not when it exists with a stale ABI. So the breakage persists across restarts.
//
// This hook probes the binary under the current Node and rebuilds it on ABI
// mismatch. Best-effort, non-blocking, always exits 0.

import { existsSync, readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { resolve, join } from "node:path";
import { homedir } from "node:os";

try {
  const ipPath = resolve(homedir(), ".claude", "plugins", "installed_plugins.json");
  if (!existsSync(ipPath)) process.exit(0);

  const ip = JSON.parse(readFileSync(ipPath, "utf-8"));
  const entries = ip?.plugins?.["context-mode@context-mode"];
  if (!Array.isArray(entries) || entries.length === 0) process.exit(0);

  // Resolve install path dynamically from the registry so it survives version bumps.
  const installPath = entries[0]?.installPath;
  if (!installPath || !existsSync(installPath)) process.exit(0);

  const pkgDir = join(installPath, "node_modules", "better-sqlite3");
  if (!existsSync(pkgDir)) process.exit(0); // not installed yet — plugin handles install

  // Probe: load the native addon in a CHILD process under the current Node.
  // dlopen cache is per-process, so the child gets a fresh load. better-sqlite3
  // lazy-loads the binary on first Database instantiation. Isolating the probe
  // in a child means even a SIGSEGV/SIGKILL on a bad binary (cf. plugin #331)
  // cannot take down this hook — execFileSync throws and we rebuild.
  let ok = false;
  try {
    execFileSync(
      process.execPath,
      ["-e", "new (require('better-sqlite3'))(':memory:').close()"],
      { cwd: installPath, stdio: "ignore", timeout: 10000 },
    );
    ok = true;
  } catch {
    ok = false;
  }
  if (ok) process.exit(0); // ABI matches — nothing to do (fast path)

  // ABI mismatch (or load failure) — rebuild better-sqlite3 for the current Node.
  // npm resolves via PATH to the same mise shim node that runs this hook and the
  // MCP server, so the rebuilt binary targets the correct ABI.
  try {
    const npm = process.platform === "win32" ? "npm.cmd" : "npm";
    execFileSync(npm, ["rebuild", "better-sqlite3", "--ignore-scripts=false"], {
      cwd: installPath,
      stdio: "ignore",
      timeout: 120000,
      shell: process.platform === "win32",
    });
  } catch {
    process.exit(0); // rebuild failed — degrade gracefully, plugin reports on first DB access
  }

  // macOS hardened runtime: re-sign the freshly built binary so a later dlopen
  // isn't SIGKILLed for an invalid signature. Best-effort.
  if (process.platform === "darwin") {
    try {
      const bin = join(pkgDir, "build", "Release", "better_sqlite3.node");
      if (existsSync(bin)) {
        execFileSync("codesign", ["--sign", "-", "--force", bin], {
          stdio: "ignore",
          timeout: 10000,
        });
      }
    } catch {
      /* codesign unavailable — continue */
    }
  }
} catch {
  /* never block session start */
}
process.exit(0);
