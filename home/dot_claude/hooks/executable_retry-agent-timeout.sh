#!/usr/bin/env bash
# PostToolUse hook for Agent tool: detect stream idle timeout and instruct retry via SendMessage

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // ""')
if [ "$tool_name" != "Agent" ]; then
  exit 0
fi

tool_response=$(echo "$input" | jq -r '.tool_response // ""')

if echo "$tool_response" | grep -q "Stream idle timeout - partial response received"; then
  agent_id=$(echo "$tool_response" | grep -oE 'agentId: [a-f0-9]+' | head -1 | awk '{print $2}')

  if [ -n "$agent_id" ]; then
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[AUTO-RETRY REQUIRED] エージェントがタイムアウトしました (agentId: ${agent_id})。自分で直接作業を続行せず、必ず SendMessage(to: '${agent_id}') で「続きを実行してください」と送信してエージェントを復帰させてください。フロントエンドのコードを直接編集してはいけません。"}}
EOF
  else
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"[AUTO-RETRY REQUIRED] エージェントがタイムアウトしました。tool_response に含まれる agentId を使って SendMessage でエージェントを復帰させてください。自分で直接作業を続行してはいけません。"}}
EOF
  fi
fi
