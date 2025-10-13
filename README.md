# ⚡ The **Ske** Programming Language

**Ske** is a modern, high-performance programming language
designed for simplicity, clarity, and expressive power.  
Built with ❤️ in [Vlang](https://vlang.io).

---

## 🚀 Features

- ✅ Lightweight and fast by design  
- ✅ Optional, strong, or dynamic typing  
- ✅ Clean and minimal syntax  
- ✅ `.ske` source files  
- ✅ Web and general-purpose scripting  
- ✅ Built-in HTTP server  
- ✅ Native routing, templating, and middleware  

---

## 🌟 Vision

**Ske** redefines how code feels to write and read —
expressive, concise, and powerful.  
Its architecture is designed for **multi-runtime execution**,
paving the way for native support in environments like TypeScript, PHP, and Vlang.

---

## 📦 Installation

> ⚠️ **Requires [Vlang](https://vlang.io)**

```bash
git clone https://github.com/siguici/ske
cd ske
v .
./ske example.ske
````

Or build for production:

```bash
v -prod .
./ske example.ske
```

---

## 📂 Project Structure

```tree
ske/
├── src/               # Parser, Interpreter, Compiler
│   ├── parser.v
│   ├── interpreter.v
│   └── compiler.v
├── examples/          # Example `.ske` files
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

Then open your browser:

[http://localhost:8080/example.ske](http://localhost:8080/example.ske)

---

## ⚙️ Configuration

Ske’s built-in server can be configured easily:

```bash
./ske serve --port 8080 --root ./examples
```

---

## 📄 Language Overview

**Ske** combines clarity and expressiveness in a clean syntax:

```ske
fn greet(name: string): string {
    return "Hello, $name!"
}

print(greet("World"))
```

### Language Features

- `print`, `echo`
- Functions, conditionals, and loops
- Optional `$` variable prefix
- Inline templates (HTML + Ske)
- Optional and strong typing
- Built-in access to HTTP and environment data

---

## 🔧 Roadmap

- [x] Core parser and runtime
- [x] Built-in HTTP server
- [x] Template rendering
- [ ] Ahead-of-time compilation
- [ ] Optional VM execution model
- [ ] Extended standard library
- [ ] WebSocket support
- [ ] Session & authentication modules
- [ ] CLI tooling for scaffolding and dev mode

---

## 🧠 Philosophy

**Ske** is about writing **natural, structured, and elegant code**.

- No tags
- No semicolons
- Just code that feels right

A minimal language for a maximal experience.

> Designed to be **clear to read**, **pleasant to write**, and **powerful to run**.

---

## 🤝 Contributing

We welcome contributions and ideas!

- 🛠 Fork this repo
- 🔧 Make improvements
- ✅ Test (`v run .`)
- 📬 Open a pull request

---

## 📜 License

[MIT](./LICENSE.md) © [Sigui Kessé Emmanuel](https://github.com/siguici)
