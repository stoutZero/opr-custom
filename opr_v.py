#!/usr/bin/env python3
import urllib.request
import json
import re
import sys

def get_latest_tag(image="neomantra/openresty", pattern=r"^(1\.31\.1\.1-\d+)-bookworm-fat"):
    try:
        # 1. Get GHCR pull token
        token_url = f"https://ghcr.io/token?service=ghcr.io&scope=repository:{image}:pull"
        req_token = urllib.request.Request(token_url)
        with urllib.request.urlopen(req_token) as resp:
            token = json.loads(resp.read().decode())["token"]

        # 2. Fetch all tags handling OCI pagination
        tags = []
        url = f"https://ghcr.io/v2/{image}/tags/list?n=1000"
        while url:
            req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode())
                tags.extend(data.get("tags", []))
                
                link = resp.headers.get("Link", "")
                m = re.search(r"\<([^>]+)\>;\s*rel=\"next\"", link)
                if m:
                    url = m.group(1)
                    if url.startswith("/"):
                        url = "https://ghcr.io" + url
                else:
                    url = None

        # 3. Filter using regex and capture the version-revision prefix group
        matched_versions = []
        for t in tags:
            if "arm64" not in t:
                m = re.match(pattern, t)
                if m:
                    matched_versions.append(m.group(1))

        # 4. Sort semantically and output the highest version prefix
        def semver_key(v):
            return [int(c) if c.isdigit() else c for c in re.split(r"(\d+)", v)]

        if matched_versions:
            print(max(set(matched_versions), key=semver_key))
            return 0
        else:
            print(f"No tags found matching pattern {pattern}", file=sys.stderr)
            return 1
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(get_latest_tag())
