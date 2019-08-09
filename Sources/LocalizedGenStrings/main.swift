import LocalizedGenStringsCore

let tool = CommandLineTool()

do {
    try tool.run()
} catch {
    Log.e("Whoops! An error occurred: \(error)")
}
