# azure-cli

Installs the `azure-cli` and its dependencies, and `azcopy`.

* https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt

**N.B.** that Microsoft does not provide an easy way to download a static
version of `azcopy` so we need to just query for it ahead of time and download
it manually.

* https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10#obtain-a-static-download-link
* https://github.com/Azure/azure-storage-azcopy/issues/1190
