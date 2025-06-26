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
    @State private var name: String
    
    @State private var show_alert_add_name = false

    init(note: Note) {
        self.note = note
        _text = State(initialValue: note.text ?? "")
        _name = State(initialValue: note.name ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                
                VStack {
                
                    // Name
                    VStack(alignment: .leading) {
                       VStack {
                            HStack {
                                Text("Name")
                                    .foregroundStyle(.black.opacity(0.41)).bold()
                                    .font(.system(size: 15))
                                    .padding(.leading, 8)
                                  
                                Spacer()
                            }
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color(hex: "#546a50").opacity(0.09))
                                    .frame(height: 50)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        TextField("Name note", text: $name)
                                            .foregroundStyle(.black.opacity(0.41)).bold()
                                            .padding(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    
                    // Text in note
                    VStack {
                        HStack {
                            Text("Text note")
                                .foregroundStyle(.black.opacity(0.41)).bold()
                                .font(.system(size: 15))
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $text)
                            .cornerRadius(20)
                            .foregroundColor(Color(hex: "#546a50"))
                            .lineSpacing(5)
                        
                    }
                        .padding()
                        
                    Spacer()
                    
                    // Delete Note
                    VStack {
                        Button {
                            deleteNote()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundStyle(.orange)
                                
                                Text("Delete note")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.orange)
                                .bold()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if name != "" && name != " " && name != "  " && name != "   " {
                                show_alert_add_name = false
                                
                                // If name is added
                                if !show_alert_add_name {
                                    saveChanges()
                                }
                                
                            } else {
                                show_alert_add_name = true
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "#546a50"))
                                .bold()
                        }
                        .alert(isPresented: $show_alert_add_name) {
                            Alert(
                                title: Text("Please add name note"),
                                message: Text(""),
                                dismissButton: .cancel()
                            )
                        }
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        note.text = text
        note.name = name
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
        note.name = "Name This test note"
        note.text = "Это текст заметки для редактирования."
        note.creationDate = Date()
        
        return EditNoteView(note: note)
            .environment(\.managedObjectContext, context)
    }
}
