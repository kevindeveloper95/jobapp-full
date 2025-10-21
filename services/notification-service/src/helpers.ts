import path from 'path';

import { IEmailLocals, winstonLogger } from '@kevindeveloper95/jobapp-shared';
import { Logger } from 'winston';
import { config } from '@notifications/config';
import nodemailer, { Transporter } from 'nodemailer';
import Email from 'email-templates';

const log: Logger = winstonLogger(`${config.ELASTIC_SEARCH_URL}`, 'mailTransportHelper', 'debug');

async function emailTemplates(template: string, receiver: string, locals: IEmailLocals): Promise<void> {
  try {
    const smtpTransport: Transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: config.SENDER_EMAIL,
        pass: config.SENDER_EMAIL_PASSWORD
      },
      tls: {
        rejectUnauthorized: false // ⚠️ Permite certificados autofirmados
      },
      logger: true, // Habilita logs
      debug: true   // Muestra información detallada
    });
    const email: Email = new Email({
      message: {
        from: `Jobber App <${config.SENDER_EMAIL}>`
      },
      send: true,
      preview: false,
      transport: smtpTransport,
      views: {
        options: {
          extension: 'ejs'
        }
      },
      juice: true,
      juiceResources: {
        preserveImportant: true,
        webResources: {
          relativeTo: path.join(__dirname, '../build')
        }
      }
    });

    await email.send({
      template: path.join(__dirname, '..', '/src/emails', template),
      message: { to: receiver },
      locals
    });
    
  } catch (error) {
    log.error(error);
  }
}

export { emailTemplates };