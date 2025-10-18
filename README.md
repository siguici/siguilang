# ⚡ The **Ske** Programming Language

**Ske** is a modern, high-performance programming language
designed for simplicity, clarity, and expressive power.  
Built with ❤️ in [Vlang](https://vlang.io).

[![Build Status](https://github.com/siguici/ske/workflows/CI/badge.svg)](https://github.com/siguici/ske/actions)

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
./ske examples
````

Or build for production:

```bash
v -prod .
./ske examples
```

## 🧪 Quick Start

Create a file `hello.ske`:

```ske
string name = scan 'Enter your name: '
if name {
  print 'Hello ', name, '!'
} else {
  print "Hello World!"
}
```

Then run it:

```bash
./ske run hello
```

---

## 📄 Language Overview

**Ske** combines clarity and expressiveness in a clean syntax:

```ske
string hello(string name) {
    return 'Hello ', name, '!'
}

print hello("World")
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
