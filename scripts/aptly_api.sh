# These options and functions are sourced from
# .github/workflows/packages.yml and used for uploading packages to
# our repos

CURL_COMMON_OPTIONS=(
  --silent
  --retry 2
  --retry-delay 3
  --user-agent 'Termux-Packages/1.0\ (https://github.com/termux/termux-packages)'
  --user "${APTLY_API_AUTH}"
  --write-out "|%{http_code}"
)
# Function for deleting temporary directory with uploaded files from
# the server.
aptly_delete_dir() {
	echo DELETE ${REPOSITORY_URL}/files/${REPOSITORY_NAME}-${GITHUB_SHA}
}

aptly_upload_file() {
	echo UPLOAD ${REPOSITORY_URL}/files/${REPOSITORY_NAME}-${GITHUB_SHA} $1
}

aptly_add_to_repo() {
  echo "[$(date +%H:%M:%S)] Adding packages to repository '$REPOSITORY_NAME'..."
}

aptly_publish_repo() {
  echo "[$(date +%H:%M:%S)] Publishing repository changes..." ${REPOSITORY_NAME}
}
