(* Mathematica Package *)
(* Created by the Wolfram Language Plugin for IntelliJ, see http://wlplugin.halirutan.de/ *)

(* :Title: wl2md *)
(* :Context: wl2md` *)
(* :Author: andrewyule *)
(* :Date: 2021-06-16 *)

(* :Package Version: 0.1 *)
(* :Mathematica Version: 12.1 *)
(* :Copyright: (c) 2021 andrewyule *)
(* :Keywords: *)
(* :Discussion: *)

BeginPackage["wl2md`"];
(* Exported symbols added here with SymbolName::usage *)

wl2md::usage = "todo";
wl2mdCompile::usage = "todo";

Begin["`Private`"];

$wl2mdDeveloperPath = "/Users/andrewyule/Dropbox (Personal)/AFS/Source Code/wl2md/wl2md";

wl2mdCompile[] := Module[{paclet = CreatePacletArchive[$wl2mdDeveloperPath]}, result = PacletInstall[paclet, ForceVersionInstall -> True]; DeleteFile[paclet]; result];

(*
  Main wl2md functions. Either a NotebookObject can be passed in or a file path.

  If a NotebookObject is given, then perform the markdown conversion and return back the string.

  If a file path is given, assume it's a notebook and run the script on the notebook and output
  a new markdown file with the same file name.
*)

wl2md[nb_NotebookObject] := Module[{cells},
  cells = Cells[nb];
  StringRiffle[wl2md /@ cells, "\n"]
];

wl2md[file_?StringQ] /; FileExistsQ[file] && FileExtension[file] == "nb" := Module[{notebookObject, markdownText},
  notebookObject = NotebookOpen[file];
  markdownText= wl2md[notebookObject];
  Export[StringReplace[file, ".nb" :> ".md"], markdownText, "Text"]
];

(* Specific support functions for handling various cell types and converting them to markdown text *)

wl2md[cell_CellObject] := wl2md[NotebookRead[cell]];
wl2md[Cell[txt_, "Subsection", ___]] := "# " <> txt;
wl2md[Cell[txt_, "Subsubsection", ___]] := "## " <> txt;
wl2md[Cell[txt_, "Text", ___]] := txt;
wl2md[Cell[boxData_, "Input", ___]] := "```\n" <> FrontEndExecute[FrontEnd`ExportPacket[boxData, "InputText"]][[1]] <> "\n```";
wl2md[Cell[boxData_, "Output", ___]] := "```\n" <> FrontEndExecute[FrontEnd`ExportPacket[boxData, "PlainText"]][[1]] <> "\n```";

End[]; (* `Private` *)

EndPackage[]