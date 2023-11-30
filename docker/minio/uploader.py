import logging
import os

import certifi
import urllib3

from minio import Minio
from minio.error import S3Error

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

def main():
    # Create a client with the MinIO server playground, its access key
    # and secret key.
    ok_http_client = urllib3.PoolManager(
        timeout=urllib3.util.Timeout(connect=10, read=10),
        maxsize=10,
        cert_reqs='CERT_NONE',
        ca_certs=os.environ.get('SSL_CERT_FILE') or certifi.where(),
        retries=urllib3.Retry(
            total=5,
            backoff_factor=0.2,
            status_forcelist=[500, 502, 503, 504]
        )
    )

    client = Minio(
        endpoint="minio.demo.com:443",
        access_key="r1xILSIAobaxemyO",
        secret_key="IAH4wKDhaEoNRzkbLkQBAA0yDpX0111W",
        secure=True,
        http_client=ok_http_client
    )

    # Make 'asiatrip' bucket if not exist.
    found = client.bucket_exists("demo")
    if not found:
        client.make_bucket("demo")
    else:
        print("Bucket 'demo' already exists")

    # Upload '/home/user/Photos/asiaphotos.zip' as object name
    # 'asiaphotos-2015.zip' to bucket 'asiatrip'.
    client.fput_object(
        "home", "uploader.py", "/home/bright/workspace/minio/uploader.py",
    )
    print(
        "successfully"
    )


if __name__ == "__main__":
    try:
        main()
    except S3Error as exc:
        print("error occurred.", exc)
