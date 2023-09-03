# packer-images

Packer images. Optionally, this repo can be used as a submodule (or just copied from).

# Usage

```bash
# create a private repo, which you use to manage deploys
gh repo create packer-deploy --private --clone
cd packer-deploy

# add this repo as a submodule
git submodule add git@github.com:fxyoge/packer-images.git packer-images

# copy over the workflows that you want
mkdir -p .github/workflows
cp packer-images/example/workflows/packer-hcloud-talos.yaml .github/workflows/packer-hcloud-talos.yaml

# adjust workflow env variables as needed - e.g. TEMPLATES_DIR if you added the submodule to a different path
# set up secrets - e.g. HCLOUD_TOKEN
# install renovate to your repo - this repo's renovate.json may be a good template
```
