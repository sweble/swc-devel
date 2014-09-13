# Sweble Wikitext Component - Development META POM

## Maven Build Profiles

### quick

**Defined in:** tooling

**Plugins:** Modifies various plugins

- Disable tests
- Don't check and format license headers
- Don't get Git commit information
- Only generate minimal site.

### git-info

**Defined in:** tooling

**Plugins:** git-commit-id-plugin

Turn on git information extraction

### sign

**Defined in:** tooling

**Plugins:** maven-gpg-plugin

Sign the generated artifacts. Usually used in conjunction with the "release"
profile to deploy artifacts to Maven Central. The key name has to be given as
option on the command line and the key should be unlocked and held by the gpg
agent (-Dgpg.keyname=...).

### release

**Defined in:** tooling

**Plugins:** maven-javadoc-plugin, maven-source-plugin, maven-deploy-plugin

This profile is used to release artifacts to Maven Central. Each module has to
build its main artifacts including javadoc and source. Signing of the artifacts
is also required BUT NOT DONE by this profile (see "sign" profile).

### build-aggregates

**Defined in:** swc-devel

**Plugins:** maven-javadoc-plugin, maven-source-plugin

- Build a aggregate javadoc JAR archive for all modules as well as aggregate HTML javadoc for all modules. This is done in the "package" phase.
- Build a aggregate sources JAR archive for all modules. This is done in the "package" phase.

### build-aggregates

**Defined in:**  swc-parser-lazy, swc-engine, sweble-wom3, ...

**Plugins:** maven-assembly-plugin

Generate a fat jar (jar-with-dependencies) for the respective project.
