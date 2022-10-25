//
//  ContentView.swift
//  Shared
//
//  Created by Manuel M T Chakravarty on 16/05/2022.
//

import SwiftUI
import Files
import ProjectNavigator


// MARK: -
// MARK: UUID serialisation

extension UUID: RawRepresentable {

  public var rawValue: String { uuidString }

  public init?(rawValue: String) {
    self.init(uuidString: rawValue)
  }
}


// MARK: -
// MARK: Views

struct FileContextMenu: View {
  let cursor: FileNavigatorCursor<Payload>

  @Binding var editedText: String?

  let proxy:       File<Payload>.Proxy
  let viewContext: ViewContext

  var body: some View {

    Button {
      editedText = cursor.name
    } label: {
      Label("Change name", systemImage: "pencil")
    }

    Divider()

    Button(role: .destructive) {

      withAnimation {
        viewContext.remove(cursor: cursor)
      }

    } label: {
      Label("Delete", systemImage: "trash")
    }

  }
}

struct FolderContextMenu: View {
  let cursor: FileNavigatorCursor<Payload>

  @Binding var editedText: String?
  @Binding var folder:     ProxyFolder<Payload>

  let viewContext: ViewContext

  var body: some View {

    Button {
      withAnimation {
        viewContext.add(item: FileOrFolder(file: File(contents: Payload(text: ""))),
                        $to: $folder,
                        withPreferredName: "Text.txt")
      }
    } label: {
      Label("New file", systemImage: "doc.badge.plus")
    }

    Button {
      withAnimation {
        viewContext.add(item: FileOrFolder(folder: Folder(children: [:])), $to: $folder, withPreferredName: "Folder")
      }
    } label: {
      Label("New folder", systemImage: "folder.badge.plus")
    }

    // Only support rename and delete action if this menu doesn't apply to the root folder
    if cursor.parent.wrappedValue != nil {

      Divider()
      
      Button {
        editedText = cursor.name
      } label: {
        Label("Change name", systemImage: "pencil")
      }

      Divider()

      Button(role: .destructive) {

        withAnimation {
          viewContext.remove(cursor: cursor)
        }

      } label: {
        Label("Delete", systemImage: "trash")
      }

    }

  }
}

struct Navigator: View {
  @ObservedObject var viewState: FileNavigatorViewState

  @EnvironmentObject var model: NavigatorDemoModel

  @Environment(\.undoManager) var undoManager: UndoManager?

  var body: some View {

    let viewContext = ViewContext(viewState: viewState, model: model, undoManager: undoManager)
    NavigationSplitView {

      List(selection: $viewState.selection) {

        FileNavigator(name: model.name,
                      item: $model.document.texts.root,
                      parent: .constant(nil),
                      viewState: viewState)
        { cursor, $editedText, proxy in

          EditableLabel(cursor.name, systemImage: "doc.plaintext.fill", editedText: $editedText)
            .onSubmit{ viewContext.rename(cursor: cursor, $to: $editedText) }
            .contextMenu{ FileContextMenu(cursor: cursor,
                                          editedText: $editedText,
                                          proxy: proxy,
                                          viewContext: viewContext) }

        } folderLabel: { cursor, $editedText, $folder in

          EditableLabel(cursor.name, systemImage: "folder.fill", editedText: $editedText)
            .onSubmit{ viewContext.rename(cursor: cursor, $to: $editedText) }
            .contextMenu{ FolderContextMenu(cursor: cursor,
                                            editedText: $editedText,
                                            folder: $folder,
                                            viewContext: viewContext) }

        }
        .navigatorFilter{ $0.first != Character(".") }
      }
      .listStyle(.sidebar)

    } detail: {

      if let uuid  = viewState.selection,
         let $file = Binding(model.document.texts.proxy(for: uuid).binding) {

        if let $text = Binding($file.contents.text) {

          TextEditor(text: $text)
            .font(.custom("HelveticaNeue", size: 15))

        } else { Text("Not a UTF-8 text file") }

      } else { Text("Select a file") }
    }
  }
}


/// This is the toplevel content view. It expects the app model as the environment object.
///
struct ContentView: View {

  @SceneStorage("navigatorExpansions") private var expansions: WrappedUUIDSet?
  @SceneStorage("navigatorSelection")  private var selection:  FileOrFolder.ID?

  @StateObject private var fileNavigationViewState = FileNavigatorViewState()

  var body: some View {

    Navigator(viewState: fileNavigationViewState)
      .task {
        if let savedExpansions = expansions {
          fileNavigationViewState.expansions = savedExpansions
        }
        for await newExpansions in fileNavigationViewState.$expansions.values {
          expansions = newExpansions
        }
      }
      .task {
        if let savedSelection = selection {
          fileNavigationViewState.selection = savedSelection
        }
        for await newSelection in fileNavigationViewState.$selection.values {
          selection = newSelection
        }
      }
  }
}


// MARK: -
// MARK: Preview

struct ContentView_Previews: PreviewProvider {

  struct Container: View {
    let document = NavigatorDemoDocument()

    var body: some View {
      ContentView()
        .environmentObject(NavigatorDemoModel(name: "Test", document: document))
    }
  }

  static var previews: some View {
    Container()
  }
}
