# TypeScript SDK for Datastar

## 🚀 Quick Start Examples

Choose your preferred JavaScript runtime and get started in seconds:

| Runtime | Example File | How to Run | Online Example | Description |
|---------|--------------|------------|----------------|-------------|
| **Node.js** | [`examples/node/node.js`](./examples/node/node.js) | [📋 Instructions](./examples/node/README.md) | _Coming soon_ | Full-featured example with package.json setup |
| **Deno** | [`examples/deno/deno.ts`](./examples/deno/deno.ts) | [📋 Instructions](./examples/deno/README.md) | [🌐 Try it live](https://www.val.town/x/eduwass/datastar-deno/code/main.tsx) | Native Deno example with web standards |
| **Bun** | [`examples/bun/bun.ts`](./examples/bun/bun.ts) | [📋 Instructions](./examples/bun/README.md) | _Coming soon_ | Modern Bun example with native routing |

> 💡 **New to Datastar?** All examples create a simple web server that demonstrates signal handling and fragment merging. Just run the command for your runtime, then visit `http://localhost:3000` in your browser!


## 📖 Documentation

> **Note:** This SDK supports multiple JavaScript runtimes: Node.js, Deno, and Bun. When developing or contributing to this SDK, you'll need to have these runtimes installed to test across all supported platforms. The main package.json scripts use Deno for building and testing, so make sure you have Deno installed as your primary development environment.

Implements the [SDK spec](../README.md) and exposes an abstract
ServerSentEventGenerator class that can be used to implement runtime specific
classes. NodeJS and web standard runtimes are currently implemented.

Currently it only exposes an http1 server, if you want http2 I recommend you use
a reverse proxy until http2 support is added.

Deno is used for building the npm package: `deno run -A build.ts` (uses version from `src/consts.ts` by default, or specify custom version as argument)

**Note:** Building is only required if you want to use the SDK as an npm package or test the examples. For running the test servers, you can run the TypeScript source files directly with Deno.

Usage is straightforward:

```javascript
// this example is for node
const reader = await ServerSentEventGenerator.readSignals(req);

if (!reader.success) {
    console.error('Error while reading signals', reader.error);
    res.end('Error while reading signals`);
    return;
}

if (!('foo' in reader.signals)) {
    console.error('The foo signal is not present');
    res.end('The foo signal is not present');
    return;
}

ServerSentEventGenerator.stream(req, res, (stream) => {
     stream.mergeSignals({ foo: reader.signals.foo });
     stream.mergeFragments(`<div id="toMerge">Hello <span data-text="$foo">${reader.signals.foo}</span></div>`);
});
```

The stream static method can receive an extra `options` object that can contain
onError and onAbort callbacks as well as the keepalive option. The keepalive
option will stop the stream from being closed once the onStart callback is
finished. That means the user is responsible for ending the stream with
`this.close()`.


## Frameworks / Alternate runtimes

If you can't simply use the node / web versions, then you can extend the
abstract class in `./src/abstractServerSentEventGenerator.ts`. You will need to
provide implementations of the `constructor`, `readSignals`, `stream` and `send`
methods.

## Testing

A shell based testing suite is provided for all supported runtimes (Node.js, Deno, and Bun). See the [readme](../test/README.md) for more information.

### Testing node

Run the complete test suite with a single command:

```shell
$ npm run test-node
```

This will automatically:
1. Build the npm package
2. Start the Node.js test server
3. Run the test suite
4. Clean up the server process

For manual testing, you can also start just the server:

```shell
$ npm run serve-node
```

Then run the test suite manually:

```shell
$ cd ../test
$ ./test-all.sh http://127.0.0.1:3000
Running tests with argument: http://127.0.0.1:3000
Processing GET cases...
Processing POST cases...
```

### Testing deno

Run the complete test suite with a single command:

```shell
$ deno task test-deno
```

This will automatically:
1. Start the Deno test server
2. Run the test suite
3. Clean up the server process

For manual testing, you can also start just the server:

```shell
$ deno task serve-deno
```

And run the tests manually like with Node (explained above).

### Testing bun

Run the complete test suite with a single command:

```shell
$ bun run test-bun
```

This will automatically:
1. Build the npm package (for shared dependencies)
2. Start the Bun test server
3. Run the test suite
4. Clean up the server process

For manual testing, you can also start just the server:

```shell
$ bun run serve-bun
```

And run the tests manually like with Node (explained above).
