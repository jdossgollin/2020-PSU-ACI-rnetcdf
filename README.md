# R, netcdf, and PSU ACI

## Disclaimers

1. I'm new to ACI. There may be better ways to do some of these things.
1. I'm using Mac. Commands may be subtly different on Windows (linux should be similar).
1. For some things that we might like to do, there are many "right" approaches. This is just one.

## Goal

1. We have written an R script on our computer that reads a netcdf file and uses `stan` to fit a Normal distribution (this is just a demo!).
1. We would now like to run this same script on PSU ACI

## Approach

1. GitHub to get source code on the cluster
1. Conda to set up R computing environment
1. Modules on PSU ACI
1. Sending output data back to laptop for analysis

## Step 1: Writing the Script

Here's a really simple example.
We read in a netcdf file and fit one variable to a normal distribution using Stan.
This isn't a meaningful thing to do, but it's a good example because both the `netcdf` and `stan` C++ libraries can be tricky to install.

* [`demo.R`](./demo.R)
* [`normal.stan`](./normal.stan)

## Step 2: Conda

Read more:

* Ryan Abernathey's [Earth and Environmental Data Science](https://earth-env-data-science.github.io/lectures/environment/python_environments.html)
* Towards Data Science [post](https://towardsdatascience.com/managing-project-specific-environments-with-conda-b8b50aa8be0e)
* [Official Docs](https://docs.conda.io/en/latest/)

**Attention**: these commands are subtly different on Windows. In particular:

1. Instead of opening `Terminal.app` or `iTerm2.app`, open the `Anaconda Prompt`
1. Instead of `conda activate <env_name>`, just type `activate <env_name>`. There are other minor syntactic differences -- see the docs.

### About

`conda` is a package manager.
If you tell it a list of packages that you want to have access to, it will figure out what dependencies those packages have, what dependencies those packages in turn have (and so on) and solve for the appropriate versions.
This is a hard problem to do well, and -- unlike R's `install.packages()` or python's `pip` -- conda seeks to install packages from any language.
This is good for us because we can install R packages _and_ dependencies like the C netcdf4 libraries.

Because sometimes different projects have conflicting dependencies, conda lets us create different environments -- essentially sandboxes -- and we can switch them by name.

### Using locally

Whenever possible, it's a good idea to make sure code runs on your own computer before running it on the cluster.

1. The most transparent way to create an environment is to specify it in a file, like [`environment.yml`](environment.yml).
1. Create the environment: `conda activate rnetcdf`
1. Forgot something you wanted to add? `conda env update --file environment.yml`
1. Run the code: `Rscript demo.R`
1. Put any output files (like `output.csv`) in your [`.gitignore`](./.gitignore) because they are _too large for `git`.

## Step 3: Cluster

First we need to get our code to the cluster.
To do that, we'll use `git` and `GitHub`.
Learn more about `git` on the Software Carpentry [Lesson](https://swcarpentry.github.io/git-novice/).
The key thing we want to keep in mind is that `git` is a good way to store `code` but a bad way to store `data`, especially binary formats like `.nc`.

### Connect

First we have to connect and navigate to our project directory

```bash
ssh -l jjd6264 aci-b.aci.ics.psu.edu
```

(if you use iTerm you can set up a password manager -- highly recommended!)
Next navigate to our directory

```bash
cd /gpfs/group/kzk10/default/private/rnetcdf-demo
```

Now clone the repository from git.
This repository is available on [my GitHub](https://github.com/jdossgollin/2020-PSU-ACI-rnetcdf).

```bash
module load git
git clone https://github.com/jdossgollin/2020-PSU-ACI-rnetcdf.git
cd 2020-PSU-ACI-rnetcdf/
```

### PBS File

See [`demo.pbs`](./demo.pbs).
To submit it:

```bash
qsub -A kzk10_a_g_sc_default demo.pbs
```
To monitor it:

```bash
qstat -u jjd6264 # replace with your ID
```

## Step 4: Get the data back

```bash
scp jjd6264@aci-b.aci.ics.psu.edu:/gpfs/group/kzk10/default/private/susquehanna_hydro/Sanjib_James_Share/ ./data/raw/sanjib
```
