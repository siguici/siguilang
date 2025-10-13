# ⚡ The **Ske** Programming Language

A modern, high-performance programming language
with PHP-inspired syntax and TypeScript-like strong typing.
No tags, no semicolons—just code naturally. Powered by [Vlang](https://vlang.io).

---

## 🚀 Features

- ✅ PHP-inspired syntax: simple, readable, and natural  
- ✅ Strong, optional, or dynamic typing like TypeScript  
- ✅ Fast execution via native V  
- ✅ Lightweight runtime (no external dependencies)  
- ✅ `.ske` file support  
- ✅ Web and general-purpose programming  
- ✅ Built-in HTTP server  
- ✅ Native routing, templating, and middleware  
- ✅ Interoperable with PHP, TypeScript, and Vlang (focus on PHP for now)

---

## 🌟 Future Potential

While **Ske** currently focuses on PHP compatibility,
its design allows for future interpretation in TypeScript and Vlang,
opening possibilities for cross-platform scripting and integration.

---

## 📦 Installation

> ⚠️ **Vlang is required**
> [Install V](https://vlang.io/)

```bash
git clone https://github.com/siguici/ske
cd ske
v .
./ske example.ske
```

Or build it:

```bash
v -prod .
./ske example.ske
```

---

## 📂 Project Structure

```tree
skelang/
├── src/               # Parser, Interpreter, Compiler
│   ├── parser.v
│   ├── interpreter.v
│   └── compiler.v
├── examples/          # Sample `.ske` files
├── LICENSE.md
└── README.md
```

---

## 🧪 Quick Start

Create a file `example.ske`:

```ske
print("Hello from Ske!")
```

Run the server:

```bash
./ske serve
```

Then open in your browser:

[http://localhost:8080/example.ske](http://localhost:8080/example.ske)

---

## ⚙️ Configuration

Basic config is done via CLI flags:

```bash
./ske serve --port 8080 --root ./examples
```

---

## 📄 Language Overview

**Ske** supports a PHP-inspired syntax with modern TypeScript-like typing:

```ske
fn greet(name: string): string {
    return "Hello, $name!"
}

print(greet("World"))
```

### Available Features

- `print`, `echo`
- Functions, conditionals, loops
- Optional `$` prefix for variables
- HTML + SkeLang mixed templates
- Strong, optional, or dynamic typing
- Built-in access to request data and server environment

---

## 🔧 Roadmap

- [x] Core parser and runtime
- [x] Built-in HTTP server
- [x] Template rendering
- [ ] Ahead-of-time (AOT) compilation
- [ ] VM-based execution model (optional)
- [ ] Standard library expansion
- [ ] WebSocket support
- [ ] Sessions & authentication
- [ ] CLI tool for scaffolding & dev server

---

## 🧠 Philosophy

**Ske** is not PHP. It's a **modern reimagining**:

- **No tags required** (`<?`, `?>`)
- **No semicolons needed** (line breaks suffice)
- **Clean, typed, structured code**
- **Modern features with minimal syntax**

> Think of it as *“PHP, redesigned with TypeScript’s typing and powered by Vlang.”*

---

## 🤝 Contributing

Pull requests, ideas, and discussions are welcome!

- 🛠 Fork this repo
- 🔧 Make changes
- ✅ Ensure it compiles (`v run .`)
- 📬 Submit a PR

---

## 📜 License

[MIT](./LICENSE.md) © [Ske Kessé Emmanuel](https://github.com/skeci)
