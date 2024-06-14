import boto3
import docker
import os
import tarfile
import re

# Initialize a session using Amazon ECR
session = boto3.Session(profile_name='default')
ecr = session.client('ecr')

# Initialize Docker client
client = docker.from_env()

# Define your repository name (not the full URI)
repository_name = 'agr_ansible_run'

def get_image_details(repository_name):
    paginator = ecr.get_paginator('describe_images')
    response_iterator = paginator.paginate(repositoryName=repository_name)

    image_details = []
    for response in response_iterator:
        for imageDetail in response['imageDetails']:
            image_details.append(imageDetail)
    
    return image_details

def sort_key(tag):
    return [int(part) for part in re.split(r'[.-]', tag) if part.isdigit()]

def pull_image(image_uri):
    image = client.images.pull(image_uri)
    return image

def check_password_file(image):
    container = client.containers.create(image)
    try:
        tar_stream, _ = container.get_archive('/.password')
        try:
            with tarfile.open(fileobj=tar_stream, mode='r|') as tar:
                for member in tar:
                    if member.name == '.password':
                        return True
        except tarfile.TarError:
            return False
    except docker.errors.NotFound:
        return False
    finally:
        container.remove()
    return False

def main():
    image_details = get_image_details(repository_name)
    results = []

    # Separate tagged and untagged images
    tagged_images = [detail for detail in image_details if 'imageTags' in detail]
    untagged_images = [detail for detail in image_details if 'imageTags' not in detail]

    # Sort tagged images by version number
    tagged_images.sort(key=lambda detail: sort_key(detail['imageTags'][0]))

    # Process tagged images
    for detail in tagged_images:
        tag = detail['imageTags'][0]
        digest = detail['imageDigest']
        image_uri = f"100225593120.dkr.ecr.us-east-1.amazonaws.com/{repository_name}:{tag}"
        print(f"Pulling image: {image_uri}")
        image = pull_image(image_uri)
        print(f"Checking for .password file in image: {image_uri}")
        found = check_password_file(image)
        if found:
            print(f".password file found in image: {image_uri}")
        else:
            print(f"No .password file found in image: {image_uri}")
        results.append((tag, digest, found))

    # Process untagged images
    for detail in untagged_images:
        digest = detail['imageDigest']
        image_uri = f"100225593120.dkr.ecr.us-east-1.amazonaws.com/{repository_name}@{digest}"
        print(f"Pulling image: {image_uri}")
        image = pull_image(image_uri)
        print(f"Checking for .password file in image: {image_uri}")
        found = check_password_file(image)
        if found:
            print(f".password file found in image: {image_uri}")
        else:
            print(f"No .password file found in image: {image_uri}")
        results.append((None, digest, found))

    # Print summary
    print("\nSummary:")
    for tag, digest, found in results:
        status = "found" if found else "not found"
        if tag:
            print(f"Image tag: {tag}, Digest: {digest}, .password file: {status}")
        else:
            print(f"Image Digest: {digest}, .password file: {status}")

if __name__ == "__main__":
    main()

