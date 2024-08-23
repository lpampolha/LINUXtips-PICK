FROM cgr.dev/chainguard/python:latest-dev as dev
WORKDIR /app
COPY ./giropops-senhas .
RUN python3 -m venv /app/venv && \
        /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
        /app/venv/bin/pip install --upgrade Flask && \
        /app/venv/bin/pip install redis==4.5.4

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
COPY --from=dev /app/venv /app/venv
COPY --from=dev /app/requirements.txt /app/
COPY --from=dev /app/templates /app/templates
COPY --from=dev /app/static /app/static
COPY --from=dev /app/app.py /app/
ENV PATH="/app/venv/bin:$PATH"
EXPOSE 5000
ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]
