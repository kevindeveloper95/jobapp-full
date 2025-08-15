import { config } from '@review/config';
import { winstonLogger } from '@kevindeveloper95/jobapp-shared';
import client, { Channel } from 'amqplib';
import { Logger } from 'winston';

const log: Logger = winstonLogger(`${config.ELASTIC_SEARCH_URL}`, 'reviewQueueConnection', 'debug');

async function createConnection(): Promise<Channel | undefined> {
  try {
    const connection = await client.connect(`${config.RABBITMQ_ENDPOINT}`,{
      clientProperties: {
        connection_name: 'review-service' 
      }
    });
    const channel = await connection.createChannel();
    log.info('review server connected to queue successfully...');
    closeConnection(channel, connection);
    return channel;
  } catch (error) {
    log.log('error', 'reviewService error createConnection() method:', error);
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