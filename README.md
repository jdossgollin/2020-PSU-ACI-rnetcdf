# R, netcdf, and PSU ACI

This repository is prepared to share a brief example of how to use conda to solve annoying dependency issues when running R on the PSU ACI cluster.

Let's pretend that we have written an R script on our computer that reads a `netcdf` file and uses `stan` to fit a Normal distribution (this is just a demo!).
This isn't a meaningful thing to do, but it's a good example because both the `netcdf` and `stan` `C++` libraries can be tricky to install, so if we can do this we can easily do more complicated things!

## Disclaimers

1. I'm new to ACI. There may be (i.e., there almost certainly are) better ways to do some of these things. If you have suggestions for improvement, please raise an Issue or submit a Pull Request on GitHub so that these instructions can stay current.
1. I'm using Mac. Commands may be subtly different on Windows (linux should be similar).

## Approach

1. GitHub to get source code on the cluster
1. Conda to set up R computing environment
1. Modules on PSU ACI
1. Sending output data back to laptop for analysis

## Step 1: Writing the Script

Here's a really simple example.
We read in a netcdf file and fit one variable to a normal distribution using Stan.

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
1. Create the environment: `conda env create --file environment.yml`
1. Activate the environment: `conda activate rnetcdf`
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

Now we have to create the repository here as well.
This is actually a time-intensive process so we should submit it as a job.
See [`makeenv.pbs`](./makeenv.pbs).

```bash
qsub -A kzk10_a_g_sc_default makeenv.pbs
```

To monitor our progress:

```bash
qstat -u jjd6264 # replace with your ID
```

We'll see something like

```
torque01.util.production.int.aci.ics.psu.edu:
                                                                                  Req'd       Req'd       Elap
Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time
----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------
22736813.torque01.util  jjd6264     batch    make-env           5934     1      1       8gb  00:10:00 R  00:00:46
[jjd6264@aci-lgn-005 2020-PSU-ACI-rnetcdf]$
```

This actually takes a while (>10 minutes is not crazy) so I've already run this step.

### PBS File

Once that's done, we can submit another job to run our code
See [`demo.pbs`](./demo.pbs).
It's good practice to make sure we have the most recent version:

```bash
git pull
```

To submit:

```bash
qsub -A kzk10_a_g_sc_default demo.pbs
```

## Step 4: Get the data back

```bash
scp jjd6264@aci-b.aci.ics.psu.edu:/gpfs/group/kzk10/default/private/rnetcdf-demo/2020-PSU-ACI-rnetcdf/output.csv ./
```

Now we can analyze the output freely on a laptop!
(There are, of course, other options like running Jupyter or RStudio on a remote server -- save that for later!)
