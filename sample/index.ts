import { AzureFunction, Context, HttpRequest } from '@azure/functions';
import puppeteer, { Browser } from 'puppeteer';

const httpTrigger: AzureFunction = async function (
  context: Context,
  req: HttpRequest
): Promise<void> {
  let browser: Browser;

  try {
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox'],
      defaultViewport: {
        width: 1200,
        height: 900,
      },
      // WindowsPCでデバッグするときはコメントアウトを外す
      // See https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#chrome-headless-doesnt-launch-on-windows
      // ignoreDefaultArgs: ['--disable-extensions'],
    });
  } catch (error) {
    context.log.error(error);
    throw new Error('Failed to launch puppeteer browser.');
  }

  try {
    const url = req.query.url || 'https://google.com/';

    const page = await browser!.newPage();
    await page.setExtraHTTPHeaders({
      'Accept-Language': 'ja-JP',
    });

    await page.goto(url);
    const screenshotBuffer: string | Buffer = await page.screenshot();

    context.res = {
      body: screenshotBuffer,
      headers: {
        'content-type': 'image/png',
      },
    };
  } catch (error) {
    context.log.error(error);
    throw new Error('Error!!');
  } finally {
    await browser!.close();
  }
};

export default httpTrigger;
