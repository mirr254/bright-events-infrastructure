#Build process set up

# base image on which we will run the application on. In this case is node verion 7
#pull the node image
FROM node:carbon as build-deps

LABEL maintainer="shammir"

#cd to the working folder
WORKDIR /usr/src/app

#copy package.json and yarn.lock into the image
COPY ./package.json ./yarn.lock ./

#install dependacies
RUN yarn

#copy everything else into the image
COPY . ./

#run the app
RUN yarn build

#production enviroment set up
FROM nginx:1.15.2-alpine

#build-deps is the name we gave that stage
COPY --from=build-deps /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

#run the server when the container starts
CMD [ "nginx", "-g", "daemon off;" ]