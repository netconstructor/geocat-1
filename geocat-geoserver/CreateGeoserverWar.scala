import scalax.io._
import Input._
import scalax.file._
import java.util.zip._

def run() {
  val geoserverURL = "http://downloads.sourceforge.net/project/geoserver/GeoServer/2.1.0/geoserver-2.1.0-bin.zip?r=http%3A%2F%2Fgeoserver.org%2Fdisplay%2FGEOS%2FStable&ts=1306506488&use_mirror=switch"


  val gsZip = Path(project("build.directory")) / "geoserver"
  gsZip.createDirectory(failIfExists=false)
  
  log.info("Downloading geoserver")
  
  Resource.fromURL(geoserverURL).acquireFor{in =>
    val zip = new ZipInputStream(in) { override def close() = () }
    var ze = zip.getNextEntry()
    while(ze != null) {
      log.info("Unzipping " + ze.getName());
      
      if(!ze.isDirectory) {
        val file = gsZip / ze.getName
        file.createFile()
        file open {seekable =>
          Stream.continually(zip.read()).takeWhile(_ != -1).foreach(i => seekable.appendIntsAsBytes(i))
        }        
      }
      
      ze = zip.getNextEntry()
      
    }
  }
}