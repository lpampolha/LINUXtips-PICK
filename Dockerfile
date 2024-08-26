FROM cgr.dev/chainguard/python:latest-dev as dev
WORKDIR /app
COPY ./giropops-senhas .
RUN python3 -m venv /app/venv && \
        /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
        /app/venv/bin/pip install --upgrade Flask && \
        /app/venv/bin/pip install redis==5.0.0b1

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
COPY --from=dev /app /app
ENV PATH="/app/venv/bin:$PATH"
EXPOSE 5000
ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]
