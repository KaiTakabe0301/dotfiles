; extends

; ファイル名から判定したホスト言語を gotmpl の地のテキストに inject する
; combined を付けることで {{ ... }} で分割された text ノードが一つの仮想ドキュメントになり、
; ブロック構造（HTML タグの開閉、JSON のオブジェクト全体など）を一体としてハイライトできる

((text) @injection.content
  (#gotmpl-host? "html")
  (#set! injection.language "html")
  (#set! injection.combined))

((text) @injection.content
  (#gotmpl-host? "yaml")
  (#set! injection.language "yaml")
  (#set! injection.combined))

((text) @injection.content
  (#gotmpl-host? "json")
  (#set! injection.language "json")
  (#set! injection.combined))

((text) @injection.content
  (#gotmpl-host? "bash")
  (#set! injection.language "bash")
  (#set! injection.combined))

((text) @injection.content
  (#gotmpl-host? "ruby")
  (#set! injection.language "ruby")
  (#set! injection.combined))
