//
//  EditNoteView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-14.
//

import SwiftUI

struct EditNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var note: Note
    @State private var text: String

    init(note: Note) {
        self.note = note
        _text = State(initialValue: note.text ?? "")
    }

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
                    
                    Button(role: .destructive, action: deleteNote) {
                        Label("Delete Note", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .padding()
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
                        Button(action: saveChanges) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        note.text = text
        note.creationDate = Date() // обновляем дату на текущую
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка при обновлении заметки: \(error.localizedDescription)")
        }
    }

    private func deleteNote() {
        viewContext.delete(note)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка удаления заметки: \(error.localizedDescription)")
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Пример заметки
        let note = Note(context: context)
        note.text = "Это текст заметки для редактирования."
        note.creationDate = Date()
        
        return EditNoteView(note: note)
            .environment(\.managedObjectContext, context)
    }
}
