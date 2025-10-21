import { config } from '@chat/config';
import { winstonLogger } from '@kevindeveloper95/jobapp-shared';
import amqp, {  Channel } from 'amqplib';
import { Logger } from 'winston';

const log: Logger = winstonLogger(`${config.ELASTIC_SEARCH_URL}`, 'chatQueueConnection', 'debug');

async function createConnection(): Promise<Channel | undefined> {
  try {
    const connection = await amqp.connect(`${config.RABBITMQ_ENDPOINT}`,{
      clientProperties: {
        connection_name: 'chat-service' // Aquí pones el nombre que quieras
      }
    });
    const channel: Channel = await connection.createChannel();
    log.info('Chat server connected to queue successfully...');
    closeConnection(channel, connection);
    return channel;
  } catch (error) {
    log.log('error', 'ChatService createConnection() method error:', error);
    return undefined;
  }
}

interface MyChannel {
  close(): Promise<void>;
}
 
interface MyConnection {
  close(): Promise<void>;
}

function closeConnection(channel: MyChannel, connection: MyConnection): void {
  process.once('SIGINT', async () => {
    await channel.close();
    await connection.close();
  });
}

export { createConnection } ;