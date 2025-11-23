FROM python:3.13-slim

WORKDIR /app

# Copy dependency files
COPY Pipfile Pipfile.lock* ./

# Install pipenv and dependencies
RUN pip install --no-cache-dir pipenv && \
    pipenv install --system --deploy --ignore-pipfile || \
    (pip install requests && echo "Installed via pip fallback")

# Copy application files
COPY interview_notify.py .
COPY file_read_backwards/ ./file_read_backwards/

# Set default environment variables (can be overridden at runtime)
ENV TOPIC="" \
    SERVER="https://ntfy.sh/" \
    LOG_DIR="/logs" \
    NICK="" \
    BOT_NICKS="Gatekeeper" \
    MODE="red" \
    CHECK_BOT_NICKS="true" \
    TEST_PHRASE="" \
    VERBOSE="0"

# Create logs directory
RUN mkdir -p /logs

# Create entrypoint script to handle environment variables
RUN echo '#!/bin/sh\n\
set -e\n\
ARGS="--topic \"${TOPIC}\" --server \"${SERVER}\" --log-dir \"${LOG_DIR}\" --nick \"${NICK}\" --bot-nicks \"${BOT_NICKS}\" --mode \"${MODE}\""\n\
if [ "${CHECK_BOT_NICKS}" = "false" ]; then\n\
  ARGS="${ARGS} --no-check-bot-nicks"\n\
fi\n\
if [ -n "${TEST_PHRASE}" ]; then\n\
  ARGS="${ARGS} --test-phrase \"${TEST_PHRASE}\""\n\
fi\n\
if [ "${VERBOSE}" -gt 0 ] 2>/dev/null; then\n\
  i=1\n\
  while [ $i -le "${VERBOSE}" ]; do\n\
    ARGS="${ARGS} -v"\n\
    i=$((i + 1))\n\
  done\n\
fi\n\
eval "exec python3 interview_notify.py ${ARGS}"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
