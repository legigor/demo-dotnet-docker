# syntax = docker/dockerfile:1

# --------------- Building the solution as one stage ---------------
FROM mcr.microsoft.com/dotnet/sdk:7.0.201 as solution

WORKDIR /sln

COPY *.sln .
COPY src/*/*.csproj .
RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done

RUN dotnet restore

COPY src src
RUN dotnet build -c Release 

# --------------- Publish apps in dedicated stages for parallelism ---------------

FROM solution AS webapp-publish
RUN dotnet publish src/Demo.WebApp/Demo.WebApp.csproj -c Release --no-restore --no-build -o /app/Demo.WebApp 

FROM solution AS runner-publish
RUN dotnet publish src/Demo.Runner/Demo.Runner.csproj -c Release --no-restore --no-build -o /app/Demo.Runner

FROM solution AS worker-publish
RUN dotnet publish src/Demo.Worker/Demo.Worker.csproj -c Release --no-restore --no-build -o /app/Demo.Worker

# --------------- Just a base runime image ---------------
FROM mcr.microsoft.com/dotnet/aspnet:7.0.3 as runtime
# https://stackoverflow.com/questions/60003204/net-3-1-application-running-inside-docker-is-failing-to-connect-sql-server
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
# Required for ImageSharp
RUN apt-get update && \
    apt-get install -y libgdiplus && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# --------------- FINAL: WebApp ---------------

FROM runtime as webapp
COPY --from=webapp-publish /app/Demo.WebApp .
ENTRYPOINT [ "dotnet", "Demo.WebApp.dll" ]

# --------------- FINAL: Runner ---------------

FROM runtime as runner

# This is another app, the runner will run with Process.Start 
COPY --from=worker-publish /app/Demo.Worker /worker

# The main app
COPY --from=runner-publish /app/Demo.Runner .


ENTRYPOINT [ "dotnet", "Demo.Runner.dll" ]