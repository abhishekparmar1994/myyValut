const { createServer } = require("http");
const { Server } = require("socket.io");
const Client = require("socket.io-client");
const Redis = require("ioredis-mock"); // Using mock for unit testing

describe("Socket.io Server Emitters & Listeners", () => {
  let io, serverSocket, clientSocket;
  const port = 3002;

  beforeAll((done) => {
    const httpServer = createServer();
    io = new Server(httpServer);
    httpServer.listen(port, () => {
      clientSocket = new Client(`http://localhost:${port}`);
      io.on("connection", (socket) => {
        serverSocket = socket;
        serverSocket.user = { id: 'test-user-1' };
      });
      clientSocket.on("connect", done);
    });
  });

  afterAll(() => {
    io.close();
    clientSocket.close();
  });

  test("should communicate message between client and server", (done) => {
    clientSocket.once("message.received", (arg) => {
      expect(arg.content).toBe("hello architect");
      done();
    });

    serverSocket.emit("message.received", { content: "hello architect" });
  });

  test("should handle chat.send listener", (done) => {
    const payload = { receiverId: 'user-2', content: 'test message' };
    
    // Server-side listener logic (simplified for test)
    serverSocket.on('chat.send', (data, callback) => {
        expect(data.receiverId).toBe('user-2');
        callback({ status: 'ok' });
        done();
    });

    clientSocket.emit('chat.send', payload, (response) => {
        expect(response.status).toBe('ok');
    });
  });

  test("should handle typing indicators", (done) => {
      serverSocket.on('chat.typing', (data) => {
          expect(data.receiverId).toBe('user-2');
          done();
      });

      clientSocket.emit('chat.typing', { receiverId: 'user-2' });
  });
});
