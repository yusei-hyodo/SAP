# 環境変数をexport
cp .env.staging .env
while read env
do
  export $env
done < .env

gcloud config set project ${FIREBASE_PROJECT_ID}
docker build -t ${FIREBASE_PROJECT_ID}-staging .
docker tag ${FIREBASE_PROJECT_ID}-staging gcr.io/${FIREBASE_PROJECT_ID}/staging
docker push gcr.io/${FIREBASE_PROJECT_ID}/staging
gcloud beta run deploy staging \
  --image gcr.io/${FIREBASE_PROJECT_ID}/staging \
  --max-instances 2 \
  --region asia-northeast1 \
  --platform managed \
  --memory 1G \
  --service-account ${GCLOUD_SERVICE_ACCOUNT_ID} \
  --allow-unauthenticated