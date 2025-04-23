const express = require('express');
const routes = require('./controller');
const { Server } = require('colyseus');
const { WebSocketTransport } = require('@colyseus/ws-transport');
const { monitor } = require('@colyseus/monitor');
const http = require('http');

const app = express();
const server = http.createServer(app);


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(routes);

const PORT = process.env.PORT || 3001;

const gameServer = new Server({
    transport: new WebSocketTransport({
      server: server  // Share the HTTP server
    })
  });

// Game state management
// class PongGame {
//   constructor() {
//     this.players = new Map();
//     this.ball = { x: 0, y: 0, dx: 0, dy: 0 };
//     this.scores = { player1: 0, player2: 0 };
//   }

//   update() {
//     // Update game state
//     this.ball.x += this.ball.dx;
//     this.ball.y += this.ball.dy;
    
//     // Check collisions
//     this.checkCollisions();
    
//     // Broadcast state
//     this.broadcastState();
//   }

//   broadcastState() {
//     const state = {
//       ball: this.ball,
//       scores: this.scores
//     };
    
//     // Use msgpack for efficient serialization
//     const binaryState = msgpack.encode(state);
//     io.emit('game-state', binaryState);
//   }
// }

// // Room management
// const rooms = new Map();

// io.on('connection', (socket) => {
//   console.log('Player connected');
  
//   socket.on('join-room', (roomId) => {
//     let room = rooms.get(roomId);
//     if (!room) {
//       room = new PongGame();
//       rooms.set(roomId, room);
//     }
    
//     socket.join(roomId);
//     room.addPlayer(socket.id);
//   });
  
//   socket.on('player-input', (input) => {
//     // Handle player input
//     const room = rooms.get(socket.room);
//     if (room) {
//       room.handleInput(socket.id, input);
//     }
//   });
// });

// Game loop  -- place in gamestate file
// setInterval(() => {
//   rooms.forEach(room => room.update());
// }, 1000 / 60); // 60 FPS

gameServer.define('pong', PongRoom);

server.listen(PORT, () =>{
    console.log(`Server is running on port ${PORT}`);
});