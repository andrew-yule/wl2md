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

filePath;

wl2md[nb_NotebookObject] := Catch[Module[{cells},
  filePath = DirectoryName[NotebookFileName[nb]];
  cells = Cells[nb];
  StringRiffle[wl2md /@ cells, "\n"]
]];

wl2md[file_?StringQ] /; FileExistsQ[file] && FileExtension[file] == "nb" := Catch[Module[{notebookObject, markdownText},
  filePath = DirectoryName[file];
  notebookObject = NotebookOpen[file];
  markdownText = wl2md[notebookObject];
  Export[StringReplace[file, ".nb" :> ".md"], markdownText, "Text"]
]];

wl2md::unrecognized = "The following expression was not able to be parsed by wl2md `1`";

(* Specific support functions for handling various cell types and converting them to markdown text *)

wl2md[cell_CellObject] := wl2md[NotebookRead[cell]];

wl2md[Cell[txt_, "Subsection", ___]] := "# " <> txt;

wl2md[Cell[txt_, "Subsubsection", ___]] := "## " <> txt;

wl2md[Cell[txt_?StringQ, "Text", ___]] := txt;

wl2md[Cell[TextData[textData_], "Text", ___]] := exportTextData[textData];

wl2md[cell : Cell[BoxData[GraphicsBox[___]], ___]] := exportCellOrBoxData[cell, "Image"];

wl2md[Cell[boxData_, "Input", ___]] := "```\n" <> exportCellOrBoxData[boxData, "InputText"] <> "\n```";

wl2md[Cell[boxData_, "Output", ___]] := "```\n" <> exportCellOrBoxData[boxData, "PlainText"] <> "\n```";

wl2md[expr___] := (Message[wl2md::unrecognized, expr]; Throw[Null]);

(* Helper functions *)

exportTextData[textData_] := StringJoin[textData /. {
  ButtonBox[txt_, BaseStyle -> "Hyperlink", ___, ButtonNote -> link_, ___] :> "[" <> txt <> "](" <> link <> ")"
}];

exportCellOrBoxData[boxData_, "InputText"] := FrontEndExecute[FrontEnd`ExportPacket[boxData, "InputText"]][[1]];

exportCellOrBoxData[boxData_, "PlainText"] := FrontEndExecute[FrontEnd`ExportPacket[boxData, "PlainText"]][[1]];

exportCellOrBoxData[cell_, "Image"] := Module[{exportedFile},
  exportedFile = Export[FileNameJoin[{filePath, CreateUUID[] <> ".png"}], cell];
  "![](" <> FileNameTake[exportedFile] <> ")"
];

End[]; (* `Private` *)

EndPackage[];