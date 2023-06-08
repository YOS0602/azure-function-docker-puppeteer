# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/node:4-node16-appservice
FROM mcr.microsoft.com/azure-functions/node:4-node18-appservice

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    DEBCONF_NOWARNINGS=yes

WORKDIR /home/site/wwwroot
COPY . /home/site/wwwroot
RUN cd /home/site/wwwroot

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init
# ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-stable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

RUN npm install \
    # NPM 利用プロジェクトにおける ユーザー名前空間再割当てエラーに対する対策
    # See https://jpazpaas.github.io/blog/2023/02/15/Docker-User-Namespace-remapping-issues.html#npm-%E5%88%A9%E7%94%A8%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8B-%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E5%90%8D%E5%89%8D%E7%A9%BA%E9%96%93%E5%86%8D%E5%89%B2%E5%BD%93%E3%81%A6%E3%82%A8%E3%83%A9%E3%83%BC
    && find /home/site/wwwroot/node_modules ! -user root | xargs --no-run-if-empty chown root:root

CMD ["google-chrome-stable"]

RUN npm run build
