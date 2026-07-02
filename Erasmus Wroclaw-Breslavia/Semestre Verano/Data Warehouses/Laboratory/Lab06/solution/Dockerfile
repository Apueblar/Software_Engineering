FROM python:3.11

# Install system dependencies
RUN pip install --upgrade pip

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gnupg2 ca-certificates && \
    # 1. Download the key
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    # 2. Add the repository
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list && \
    # 3. Install the driver
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 unixodbc-dev

# Set the working directory
WORKDIR /app

# Copy and install Python requirements
# Assuming you move your 'pip install' here for better performance
RUN pip install dlt[mssql] dlt[sql_database] pyodbc dbt-sqlserver dbt-duckdb duckdb pymssql streamlit
# Keep container running
CMD ["tail", "-f", "/dev/null"]