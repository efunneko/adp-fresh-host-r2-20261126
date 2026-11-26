<!-- tera:begin stamp=tera@v0.8.0-rc.31/c932b5c01f1dc3c01f0a06c9791da3787a5e154173ac4dab3c2cd4307e636286 -->
## tera

Work in this repository runs through tera, a work engine: a request becomes
a Work Order, which tera dispatches to a harness session, holds while it runs,
and parks when it needs a person to answer. Reach it through the `tera` MCP
server, or the `tera` CLI where that server is not configured.

tera acts on the deployment of the selected client context: `tera context show`
names it, and every tool call and command here reaches that deployment.

How work is planned, built, reviewed and landed here is the process in
`.tera/process.md`. Follow it rather than inventing one.

| When the person asks to | Use the skill |
|---|---|
| learn how any part of tera works | `tera` |
| review the setup once `tera audit` passes | `tera-audit` |

To set tera up, read the brief `tera get-started` prints: the rules setup keeps, and how to
search and read tera's knowledge in place. To check the setup, run `tera audit`.
<!-- tera:end -->
