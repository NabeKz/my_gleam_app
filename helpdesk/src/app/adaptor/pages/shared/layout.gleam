import lib/http_core

pub fn style_sheet(
  req: http_core.Request,
  handle_request: fn(http_core.Request) -> String,
) -> String {
  "<head>
    <style>
      ul, li, form { margin: 0; }
      form { button[type=submit] { margin-top: 10px; }}
    </style>
  </head>" <> handle_request(req)
}

pub fn public(
  req: http_core.Request,
  f: fn(http_core.Request) -> String,
) -> String {
  "<main>" <> f(req) <> "</main>"
}
