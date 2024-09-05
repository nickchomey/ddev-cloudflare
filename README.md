## DDEV-Cloudflare
This ddev addon helps you easily serve your ddev projects with real public subdomains via Cloudflare Tunnels

### Commands:
* `ddev cloudflare install` - installs, if necessary, the appropriate `cloudflared` and `flarectl` tools for your OS and CPU Architecture needed to automatically manage your Cloudflare Tunnels from the command line.
    * `cloudflared` is for creating, managing and communicating over the actual tunnels. A systemd service will be created for it
    * `flarectl` will create, update and delete the DNS records in your Cloudflare account that are used to route the traffic to the appropriate tunnel (and, consequently, server(s))
* `ddev cloudflare connect` - (re)connects a Cloudflare Tunnel to the local server.
    * This only needs to be run once - as all traffic for all projects and domains will go through a single tunnel.
    * It is run automaticallly when you initially `install`, but can be re-run to change the configuration
* `ddev cloudflare serve` - Run this from within a DDEV project to set up new tunnel routes for that project's hostnames/fqdns
    * It will prompt you for fqdns(s) to link to the DDEV project. It automatically sets the `additional_fqdns` field in the project's `config.yaml`, and also sets up any required DNS records (or clears unused ones).
    * It will then restart the project, and you should be able to access the project from any public fqdns that you set - Cloudflare Tunnels and DDEV Traefik Router will handle it all.

## Requirements
* A Cloudflare account with at least one domain name/"zone"
* Create an API Token that can edit Zone DNS. [Docs here](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/). You can specify which zones/domains you want it to have access to, or allow it to access all of your zones. If you have access to multiple accounts (e.g. personal, professional, client etc...), you may want to include access to only specific ones.


## Help Needed
This has only been tested on Ubuntu 24.04 in WSL2. However, code is in place to install and configure everything for other Linux Distros, macOS, and Windows. I assume that it does not work perfectly (or perhaps even at all) - in particular setting up `cloudflared` to run as a [system service](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/as-a-service/).

Likewise, the workflow and integration with DDEV is probably not ideal.

So, testing, debugging and contributions are very welcome.


## Components of the repository

* The fundamental contents of the add-on service or other component. For example, in this template there is a [docker-compose.ddev-cloudflare.yaml](docker-compose.ddev-cloudflare.yaml) file.
* An [install.yaml](install.yaml) file that describes how to install the service or other component.
* A test suite in [test.bats](tests/test.bats) that makes sure the service continues to work as expected.
* [Github actions setup](.github/workflows/tests.yml) so that the tests run automatically when you push to the repository.

## Getting started

6. Update `tests/test.bats` to provide a reasonable test for your repository. Tests are triggered either by manually executing `bats ./tests/test.bats`, automatically on every push to the repository, or periodically each night. Please make sure to attend to test failures when they happen. Others will be depending on you. Bats is a simple testing framework that just uses Bash. To run a Bats test locally, you have to [install bats-core](https://bats-core.readthedocs.io/en/stable/installation.html) first. Then you download your add-on, and finally run `bats ./tests/test.bats` within the root of the uncompressed directory. To learn more about Bats see the [documentation](https://bats-core.readthedocs.io/en/stable/).
7. When everything is working, including the tests, you can push the repository to GitHub.
8. Create a [release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) on GitHub.
9. Test manually with `ddev get <owner/repo>`.
10. You can test PRs with `ddev get https://github.com/<user>/<repo>/tarball/<branch>`
11. Update the `README.md` to describe the add-on, how to use it, and how to contribute. If there are any manual actions that have to be taken, please explain them. If it requires special configuration of the using project, please explain how to do those. Examples in [ddev/ddev-solr](https://github.com/ddev/ddev-solr), [ddev/ddev-memcached](https://github.com/ddev/ddev-memcached), and (advanced) [ddev-platformsh](https://github.com/ddev/ddev-platformsh).


Add-ons were covered in [DDEV Add-ons: Creating, maintaining, testing](https://www.dropbox.com/scl/fi/bnvlv7zswxwm8ix1s5u4t/2023-11-07_DDEV_Add-ons.mp4?rlkey=5cma8s11pscxq0skawsoqrscp&dl=0) (part of the [DDEV Contributor Live Training](https://ddev.com/blog/contributor-training)).

Note that more advanced techniques are discussed in [DDEV docs](https://ddev.readthedocs.io/en/latest/users/extend/additional-services/#additional-service-configurations-and-add-ons-for-ddev).

## How to debug tests (Github Actions)

1. You need an SSH-key registered with GitHub. You either pick the key you have already used with `github.com` or you create a dedicated new one with `ssh-keygen -t ed25519 -a 64 -f tmate_ed25519 -C "$(date +'%d-%m-%Y')"` and add it at `https://github.com/settings/keys`.

2. Add the following snippet to `~/.ssh/config`:

```
Host *.tmate.io
    User git
    AddKeysToAgent yes
    UseKeychain yes
    PreferredAuthentications publickey
    IdentitiesOnly yes
    IdentityFile ~/.ssh/tmate_ed25519
```
3. Go to `https://github.com/<user>/<repo>/actions/workflows/tests.yml`.

4. Click the `Run workflow` button and you will have the option to select the branch to run the workflow from and activate `tmate` by checking the `Debug with tmate` checkbox for this run.

![tmate](images/gh-tmate.jpg)

5. After the `workflow_dispatch` event was triggered, click the `All workflows` link in the sidebar and then click the `tests` action in progress workflow.

7. Pick one of the jobs in progress in the sidebar.

8. Wait until the current task list reaches the `tmate debugging session` section and the output shows something like:

```
106 SSH: ssh PRbaS7SLVxbXImhjUqydQBgDL@nyc1.tmate.io
107 or: ssh -i <path-to-private-SSH-key> PRbaS7SLVxbXImhjUqydQBgDL@nyc1.tmate.io
108 SSH: ssh PRbaS7SLVxbXImhjUqydQBgDL@nyc1.tmate.io
109 or: ssh -i <path-to-private-SSH-key> PRbaS7SLVxbXImhjUqydQBgDL@nyc1.tmate.io
```

9. Copy and execute the first option `ssh PRbaS7SLVxbXImhjUqydQBgDL@nyc1.tmate.io` in the terminal and continue by pressing either <kbd>q</kbd> or <kbd>Ctrl</kbd> + <kbd>c</kbd>.

10. Start the Bats test with `bats ./tests/test.bats`.

For a more detailed documentation about `tmate` see [Debug your GitHub Actions by using tmate](https://mxschmitt.github.io/action-tmate/).

**Contributed and maintained by [@CONTRIBUTOR](https://github.com/CONTRIBUTOR)**
