# OtterScale Charts

A collection of Helm Charts for deploying and managing various infrastructure components and applications on Kubernetes clusters.

## Quickstart

To get started, add the OtterScale Chart repository to your Helm configuration:

```sh
# Add the repository as follows
$ helm repo add otterscale https://otterscale.github.io/charts
$ helm repo update
```

## Usage

Once the repository is updated, you can search for available charts and install them:

```sh
# Search for available charts
$ helm search repo otterscale

# Example: Install a chart
$ helm install my-release otterscale/chart-name
```
