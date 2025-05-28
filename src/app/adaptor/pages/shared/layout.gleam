import lib/http_core

pub fn style_sheet(
  req: http_core.Request,
  handle_request: fn(http_core.Request) -> String,
) -> String {
  "<head>
    <style>
      ul, li { margin: 0; }
    </style>
  </head>" <> handle_request(req)
}

pub fn public(
  req: http_core.Request,
  f: fn(http_core.Request) -> String,
) -> String {
  "<main>" <> "</main>"
}
