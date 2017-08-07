name := "enry-java"
organization := "tech.sourced"
version := "1.0"

crossPaths := false
autoScalaLibrary := false
publishMavenStyle := true
exportJars := true

libraryDependencies += "com.novocode" % "junit-interface" % "0.11" % Test

unmanagedBase := baseDirectory.value / "lib"
unmanagedClasspath in Test += baseDirectory.value / "shared"
unmanagedClasspath in Runtime += baseDirectory.value / "shared"
unmanagedClasspath in Compile += baseDirectory.value / "shared"
testOptions += Tests.Argument(TestFrameworks.JUnit)

lazy val buildNative = taskKey[Unit]("builds native code")

buildNative := {
  def execCmd(cmd: String, errMsg: String): Unit = {
    val res = cmd !;
    if (res != 0) throw new RuntimeException(errMsg)
  }

  val os = System.getProperty("os.name").toLowerCase();
  if (os.contains("linux")) {
    execCmd("make linux-shared", "unable to build linux shared library")
  } else if (os.contains("mac os")) {
    execCmd("make darwin-shared", "unable to build darwin dynamic library")
  } else {
    throw new RuntimeException("can't build a shared library for " + os)
  }

  execCmd("make", "unable to generate jar from shared library")
}

test := {
  buildNative.value
  (test in Test).value
}

compile := {
  buildNative.value
  (compile in Compile).value
}

assembly := {
  buildNative.value
  assembly.value
}
