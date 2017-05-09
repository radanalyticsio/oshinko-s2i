package io.radanalytics.sbt.plugin.sbtsparkhelper

import sbt._
import sbt.Keys._
import SbtSparkHelper.DEFAULT_PACKAGES_FILE_NAME
import SbtSparkHelper.DEFAULT_JARS_FILE_NAME

object SbtSparkHelperPlugin extends AutoPlugin {

  override def trigger: PluginTrigger = AllRequirements

  object autoImport {
    val sbtSparkPackagesFile = SbtSparkHelperKeys.sbtSparkPackagesFile
    val sbtSparkJarsFile = SbtSparkHelperKeys.sbtSparkJarsFile
    val writePackages = SbtSparkHelperKeys.writePackages
    val writeJars = SbtSparkHelperKeys.writeJars
  }

  import autoImport._

  override lazy val projectSettings = Seq(

    SbtSparkHelperKeys.collectModuleIDs := {
      val classpath: Seq[Attributed[File]] =
        Classpaths.managedJars(Runtime, classpathTypes.value, update.value)

      classpath.flatMap { entry =>
        for {
          art: Artifact <- entry.get(artifact.key)
          mod: ModuleID <- entry.get(moduleID.key)
        } yield {
          sLog.value.debug(s"""${mod.organization}:${mod.name}:${mod.revision}""")
          mod
        }
      }
    },

    SbtSparkHelperKeys.collectAppJars := {
      val classpath: Seq[File] = (dependencyClasspath in Runtime).value.files 
      classpath
    },

    writePackages := {
      val packagesFile = new File(baseDirectory.value, sbtSparkPackagesFile.value)
      val allModules = SbtSparkHelperKeys.collectModuleIDs.value
      SbtSparkHelper.doPackages(allModules, packagesFile, sLog.value)
    },

    writeJars := {
      val jarsFile = new File(baseDirectory.value, sbtSparkJarsFile.value)
      val allJars = SbtSparkHelperKeys.collectAppJars.value
      SbtSparkHelper.doJars(allJars, jarsFile, sLog.value)
    }
  )

  override val globalSettings = Seq(
    sbtSparkPackagesFile := DEFAULT_PACKAGES_FILE_NAME,
    sbtSparkJarsFile := DEFAULT_JARS_FILE_NAME
  )
}
