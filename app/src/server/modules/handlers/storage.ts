import { join } from 'path'
import { Storage } from '@google-cloud/storage'
import { storageBucketName } from '../../config/env'

const keyFilename = join(__dirname, '/../../../../key/gcloud.json')
const storage = new Storage({ keyFilename })

const bucket = storage.bucket(storageBucketName)

export const storageSetPublic = (filePath: string): Promise<any> => bucket.file(filePath).makePublic()

export const storageDeleteItem = async (filePath: string): Promise<void> => {
  await bucket.file(filePath).delete()
}
