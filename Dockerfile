FROM node:17-alpine3.12 AS deps
RUN apk upgrade --update && apk add --no-cache python3 python3-dev



WORKDIR /app
COPY * ./


ARG CF_SPACE_ID
ARG CF_DELIVERY_ACCESS_TOKEN
ARG CF_PREVIEW_ACCESS_TOKEN
ARG CF_ENVIRONMENT
ARG PORT=8000
ARG PATREON_ACCESS_TOKEN
ARG PATREON_CAMPAIGN_ID
ARG MAILCHIMP_AUDIENCE_ID


ARG GOOGLE_TAG_MANAGER_CONTAINER_ID
ENV NEXT_PUBLIC_GOOGLE_TAG_MANAGER_CONTAINER_ID=$GOOGLE_TAG_MANAGER_CONTAINER_ID


RUN yarn install

ENV NODE_ENV production

RUN apk add --no-cache tini


ENV CF_SPACE_ID=$CF_SPACE_ID
ENV CF_DELIVERY_ACCESS_TOKEN=$CF_DELIVERY_ACCESS_TOKEN
ENV CF_PREVIEW_ACCESS_TOKEN=$CF_PREVIEW_ACCESS_TOKEN
ENV CF_ENVIRONMENT=$CF_ENVIRONMENT
ENV PATREON_ACCESS_TOKEN=$PATREON_ACCESS_TOKEN
ENV PATREON_CAMPAIGN_ID=$PATREON_CAMPAIGN_ID
ENV MAILCHIMP_AUDIENCE_ID=$MAILCHIMP_AUDIENCE_ID

RUN deluser --remove-home node && addgroup -S node -g 10000 && adduser -S -G node -u 10001 node

COPY --chown=node:node . .
COPY --chown=node:node ./public /app/public
COPY --chown=node:node ./node_modules /app/node_modules 
COPY  --chown=node:node ./package.json /app/package.json 
COPY --chown=node:node start.sh .
ADD start.sh /
RUN chmod +x start.sh
RUN chmod +x *

USER node

ENV PORT=${PORT}
EXPOSE ${PORT}

ENV NEXT_TELEMETRY_DISABLED 1



RUN nohup yarn watch &
WORKDIR /app/public
EXPOSE  8080
CMD ["/app/start.sh"]



