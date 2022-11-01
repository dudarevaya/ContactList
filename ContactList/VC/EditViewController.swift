//
//  EditViewController.swift
//  M20
//
//  Created by Яна Дударева on 11.09.2022.
//

import Foundation
import UIKit
import CoreData

class EditViewController: UIViewController {
    
    private let birth: String
    private var occupation: String
    private let name: String
    private let lastName: String
    private let country: String

    init(birth: String, occupation: String, name: String, lastName: String, country: String) {
        self.birth = birth
        self.occupation = occupation
        self.name = name
        self.lastName = lastName
        self.country = country
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "M20")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }

        return container
    }()
    
    var info: InfoData?
    
    //MARK: Views
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        return label
    }()
    
    private lazy var nameInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = name
        
        textField.addTarget(self, action: #selector(checkError(textField:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var errorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Last name:"
        return label
    }()
    
    private lazy var lastNameInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = lastName
        
        textField.addTarget(self, action: #selector(checkError(textField:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var errorLastNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var birthLabel: UILabel = {
        let label = UILabel()
        label.text = "Year of birth:"
        return label
    }()
    
    private lazy var birthInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.text = birth
        
        textField.addTarget(self, action: #selector(checkError(textField:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var errorBirthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var occupationLabel: UILabel = {
        let label = UILabel()
        label.text = "Type of employment:"
        return label
    }()
    
    private lazy var occupationInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.text = occupation
        textField.addTarget(self, action: #selector(checkError(textField:)), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var errorOccupationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var countryLabel: UILabel = {
        let label = UILabel()
        label.text = "Country:"
        return label
    }()
    
    var countries: [String] = []
    
    private lazy var countryInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        
        textField.text = country
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        textField.inputView = pickerView
        
        return textField
    }()
    
    private lazy var buttonSave: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .gray
        
        button.addTarget(self, action: #selector(saveData), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nameInput)
        stackView.addArrangedSubview(errorNameLabel)
        stackView.addArrangedSubview(lastNameLabel)
        stackView.addArrangedSubview(lastNameInput)
        stackView.addArrangedSubview(errorLastNameLabel)
        stackView.addArrangedSubview(birthLabel)
        stackView.addArrangedSubview(birthInput)
        stackView.addArrangedSubview(errorBirthLabel)
        stackView.addArrangedSubview(occupationLabel)
        stackView.addArrangedSubview(occupationInput)
        stackView.addArrangedSubview(errorOccupationLabel)
        stackView.addArrangedSubview(countryLabel)
        stackView.addArrangedSubview(countryInput)
        stackView.addArrangedSubview(buttonSave)
        stackView.spacing = 5
        stackView.setCustomSpacing(20, after: countryInput)
        return stackView
    }()
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let info = info {
            nameInput.text = info.name
            lastNameInput.text = info.lastName
            birthInput.text = info.birth
            occupationInput.text = info.occupation
            countryInput.text = info.country
        }
        
        self.countries = self.getCountryList()
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: ViewModels
    
    @objc func saveData() {
        if nameInput.text == "" {
            nameInput.text = name
        }
        if birthInput.text == "" {
            birthInput.text = birth
        }
        if occupationInput.text == "" {
            occupationInput.text = occupation
        }
        if lastNameInput.text == "" {
            lastNameInput.text = lastName
        }
        if countryInput.text == "" {
            countryInput.text = country
        }
        
        info?.name = nameInput.text
        info?.lastName = lastNameInput.text
        info?.birth = birthInput.text
        info?.occupation = occupationInput.text
        info?.country = countryInput.text
        
        try? info?.managedObjectContext?.save()
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func checkError(textField: UITextField) {
         if textField == nameInput {
             for t in textField.text! {
                 if t.isNumber{
                     errorNameLabel.text = "invalid input"
                     errorNameLabel.textColor = .systemRed
                 } else {
                     errorNameLabel.text = ""
                 }
             }
         } else if textField == lastNameInput {
             for t in textField.text! {
                 if t.isNumber {
                     errorLastNameLabel.text = "invalid input"
                     errorLastNameLabel.textColor = .systemRed
                 } else {
                     errorLastNameLabel.text = ""
                 }
             }
         } else if textField == birthInput {
             for t in textField.text! {
                 if t.isNumber == false || textField.text?.count != 4 {
                     errorBirthLabel.text = "invalid input"
                     errorBirthLabel.textColor = .systemRed
                 } else {
                     errorBirthLabel.text = ""
                 }
             }
         } else if textField == occupationInput {
             for t in textField.text! {
                 if t.isNumber {
                     errorOccupationLabel.text = "invalid input"
                     errorOccupationLabel.textColor = .systemRed
                 } else {
                     errorOccupationLabel.text = ""
                 }
             }
         }
    }

    func getCountryList() -> [String] {
        var countries: [String] = []
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: .identifier, value: id) ?? "Country not found"
            countries.append(name)
        }
        return countries
    }
    
    private func setupViews() {
    view.addSubview(stackView)
    }
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
    }
}

// MARK: Extensions
extension EditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.countries.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.countries[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryInput.text = self.countries[row]
    }
}
