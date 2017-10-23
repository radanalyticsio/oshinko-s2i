package io.radanalytics.sbt.plugin.sbtsparkhelper

import sbt.{ ModuleID, _ }

object SbtSparkHelperKeys {
  val sbtSparkPackagesFile = settingKey[String]("The name of the application dependency packages file.")
  val sbtSparkJarsFile = settingKey[String]("The name of the file listing application dependency jars.")
  val writePackages = taskKey[File]("Create a file with a list of packages as Maven coordinates to be passed to spark-submit")
  val writeJars = taskKey[File]("Create a file and directory of dependency jars to be passed to spark-submit")
  val collectModuleIDs = taskKey[Seq[ModuleID]]("Collect application dependency ModuleIDs")
  val collectAppJars = taskKey[Seq[File]]("Collect application dependency jars")
}
