//
//  AddNoteView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-14.
//

import SwiftUI
import FirebaseAnalytics

struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var name: String = ""

    @State private var show_alert_add_name = false

    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?

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
                                
                                TextField("Name note", text: $name)
                                    .foregroundStyle(.black.opacity(0.41)).bold()
                                    .padding(.leading)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    // Text note
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
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            logDismissTap()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.orange)
                                .bold()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            logSaveTap()
                            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                show_alert_add_name = true
                                logAlertShown()
                            } else {
                                saveNote()
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
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("add_note_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("add_note_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }

    private func saveNote() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newNote = Note(context: viewContext)
        newNote.name = name
        newNote.text = text
        newNote.creationDate = Date()
        newNote.id = UUID()

        do {
            try viewContext.save()
            Analytics.logEvent("add_note_saved", parameters: [
                "note_name_length": name.count,
                "text_length": text.count
            ])
            lastActionTime = Date()
            dismiss()
        } catch {
            print("Ошибка сохранения заметки: \(error.localizedDescription)")
        }
    }

    private func logDismissTap() {
        logAction(event: "add_note_dismiss_tap")
    }
    
    private func logSaveTap() {
        logAction(event: "add_note_save_tap")
    }
    
    private func logAlertShown() {
        logAction(event: "add_note_alert_shown")
    }

    private func logAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent(event, parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent(event, parameters: nil)
        }
        lastActionTime = now
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        AddNoteView().environment(\.managedObjectContext, context)
    }
}

/*
struct AddNoteView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var name: String = ""

    @State private var show_alert_add_name = false
    
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
                                    saveNote()
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

    private func saveNote() {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let newNote = Note(context: viewContext)
        newNote.name = name
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
*/
