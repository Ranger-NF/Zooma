import { createServer } from 'http';
import App from './app';
import { DatabaseConnection } from '@/database/connection';
import { SocketManager } from '@/socket/socketManager';

class Server {
  private app: App;
  private port: number;
  private dbConnection: DatabaseConnection;
  private socketManager: SocketManager;

  constructor() {
    this.app = new App();
    this.port = parseInt(process.env.PORT || '3000', 10);
    this.dbConnection = DatabaseConnection.getInstance();
    this.socketManager = SocketManager.getInstance();
  }

  public async start(): Promise<void> {
    try {
      // Connect to database
      await this.dbConnection.connect();
      console.log('✅ Database connected successfully');

      // Create HTTP server
      const server = createServer(this.app.getApp());

      // Initialize Socket.IO
      this.socketManager.initialize(server);
      console.log('✅ Socket.IO initialized successfully');

      // Start server
      server.listen(this.port, () => {
        console.log(`🚀 Bingo Game Server running on port ${this.port}`);
        console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
        console.log(`📁 Uploads directory: uploads/`);
        
        if (process.env.NODE_ENV === 'development') {
          console.log(`🔗 API Base URL: http://localhost:${this.port}/api`);
          console.log(`🔗 Health Check: http://localhost:${this.port}/api/health`);
        }
      });

      // Graceful shutdown handling
      this.setupGracefulShutdown(server);

    } catch (error) {
      console.error('❌ Failed to start server:', error);
      process.exit(1);
    }
  }

  private setupGracefulShutdown(server: any): void {
    const shutdown = async (signal: string) => {
      console.log(`\n📡 Received ${signal}. Starting graceful shutdown...`);

      // Stop accepting new connections
      server.close(async () => {
        console.log('🔒 HTTP server closed');

        try {
          // Close database connection
          await this.dbConnection.disconnect();
          console.log('🔌 Database disconnected');

          console.log('✅ Graceful shutdown completed');
          process.exit(0);
        } catch (error) {
          console.error('❌ Error during shutdown:', error);
          process.exit(1);
        }
      });

      // Force shutdown after 30 seconds
      setTimeout(() => {
        console.error('⚠️  Forceful shutdown after timeout');
        process.exit(1);
      }, 30000);
    };

    // Handle different termination signals
    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      console.error('💥 Uncaught Exception:', error);
      shutdown('UNCAUGHT_EXCEPTION');
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
      shutdown('UNHANDLED_REJECTION');
    });
  }
}

// Start the server
const server = new Server();
server.start().catch((error) => {
  console.error('💥 Server startup failed:', error);
  process.exit(1);
});