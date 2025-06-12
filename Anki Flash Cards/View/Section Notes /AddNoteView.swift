//
//  AddNoteView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-14.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#4A6C5A")
                    .ignoresSafeArea()
                
                
                VStack {
                   TextEditor(text: $text)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: saveNote) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                }
            }
        }
    }

    private func saveNote() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newNote = Note(context: viewContext)
        newNote.text = text
        newNote.creationDate = Date()
        newNote.id = UUID()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка сохранения заметки: \(error.localizedDescription)")
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        return AddNoteView()
            .environment(\.managedObjectContext, context)
    }
}
