# dockerize shiny app

# browseURL("https://www.r-bloggers.com/2025/06/containerizing-shiny-apps-with-shiny2docker-a-step-by-step-guide/")

if(!require(shiny2docker)) install.packages("shiny2docker")

library(shiny2docker)

# create a dockerfile
shiny2docker(path = ".")

# build docker image

# Make sure you are in the directory with the Dockerfile
# Replace 'myshinyapp' with the name you want for your Docker image.
# docker build -t covid19dash .


# run shiny app in a docker container
