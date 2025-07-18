# ⚡ VHP - Vlang Hypertext Preprocessor

**VHP** is a modern, lightweight, and fast web scripting engine inspired by PHP,
written entirely in [Vlang](https://vlang.io).

It preserves much of PHP’s familiar syntax, while offering improved performance,
better type safety, and native integration with V’s ecosystem —
without relying on the Zend Engine.

---

## 🚀 Features

- ✅ Familiar PHP-like syntax
- ✅ Strong/optional typing
- ✅ Fast execution via native V
- ✅ Built-in HTTP server (no Apache/Nginx)
- ✅ `.vhp` file support (like `.php`)
- ✅ Dynamic interpretation or ahead-of-time (AOT) compilation
- ✅ Lightweight runtime (no external dependencies)
- ✅ Native routing, templating, and middleware
- ✅ Interop with V modules

---

## 📦 Installation

> ⚠️ **Vlang is required.*  
> [Install V](https://vlang.io/)

```bash
git clone https://github.com/siguici/vhp
cd vhp
v run . hello.vhp
````

Or build it:

```bash
v -prod .
./vhp run hello.vhp
```

---

## 📂 Project Structure

```tree
vhp/
├── core/               # Parser, Interpreter, Compiler
│   ├── parser.v
│   ├── interpreter.v
│   └── compiler.v
├── server/             # HTTP Server & Routing
│   ├── router.v
│   ├── middleware.v
│   └── response.v
├── templates/          # Template Engine
├── examples/           # Sample `.vhp` files
├── stdlib/             # Standard functions (echo, strlen, etc.)
├── vhp.v               # Entry point
└── README.md
```

---

## 🧪 Quick Start

Create a file `index.vhp`:

```php
<?php
echo "Hello from VHP!";
?>
```

Run the server:

```bash
./vhp serve
```

Then open in your browser:

[http://localhost:8080/index.vhp](http://localhost:8080/index.vhp)

---

## ⚙️ Configuration

Basic config is done via CLI flags:

```bash
./vhp serve --port 8080 --root ./examples
```

---

## 📄 Language Overview

VHP supports a PHP-inspired syntax with modern Vlang concepts:

```php
<?php
fn greet(name: string): string {
    return "Hello, $name!";
}

echo greet("World");
?>
```

### Available Features

- `echo`, `print`
- Functions, conditionals, loops
- Variables with `$` prefix (optional)
- HTML + VHP mixed templates
- Basic type annotations
- Access to `$_GET`, `$_POST`, `$_SERVER`, etc.

---

## 🔧 Roadmap

- [x] Basic `.vhp` parser and runtime
- [x] Built-in HTTP server
- [x] Template rendering
- [ ] AOT compilation to `.v` or bytecode
- [ ] VM-based execution model (optional)
- [ ] Standard library expansion
- [ ] PHP function compatibility layer
- [ ] WebSocket support
- [ ] Sessions & authentication
- [ ] CLI tool for scaffolding & dev server

---

## 🧠 Philosophy

VHP is not a clone of PHP. It's a reimagined alternative:

- **No Zend Engine**
- **No bloated runtime**
- **Clean, typed, structured code**
- **Modern features with old-school simplicity**

> Think of it as *“PHP, if it were designed in 2025, in Vlang.”*

---

## 🤝 Contributing

Pull requests, ideas, and discussions are welcome!

- 🛠 Fork this repo
- 🔧 Make changes
- ✅ Ensure it compiles (`v run vhp.v`)
- 📬 Submit a PR

---

## 📜 License

MIT © \[Your Name]

---

## 🔗 Resources

- [V Language](https://vlang.io)
- [PHP Manual](https://www.php.net/manual/en/)
- [Building interpreters in V](https://github.com/vlang/v/issues/4827)
