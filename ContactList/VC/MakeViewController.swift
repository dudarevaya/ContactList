//
//  MakeViewController1.swift
//  M19
//
//  Created by Яна Дударева on 26.06.2022.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import CoreData


class MakeViewController: UIViewController {
    
    var isEmpty = true
    
    var info: InfoData?
    
    let persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "M20")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }

        return container
    }()
    
    var id = 0
    var idArr: [Int] = []
    
    //MARK: Views
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        return label
    }()
    
    private lazy var nameInput: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        
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
        
        buttonSave.isEnabled = false
        buttonSave.alpha = 0.5
        [nameInput, lastNameInput].forEach {
                $0?.addTarget(self,
                              action: #selector(editingChanged(_:)),
                              for: .editingChanged)
            }
        
        self.countries = self.getCountryList()
        self.navigationItem.hidesBackButton = true
        
        if let info = info {
            nameInput.text = info.name
            lastNameInput.text = info.lastName
            birthInput.text = info.birth
            occupationInput.text = info.occupation
            countryInput.text = info.country
        }
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: ViewModels
    
    @objc func editingChanged(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        buttonSave.isEnabled = ![nameInput, lastNameInput].compactMap {
            $0.text?.isEmpty
        }.contains(true)
        if nameInput.text != "" && lastNameInput.text != "" {
            buttonSave.alpha = 1.0
        }
    }
    
    @objc func saveData() {
        if nameInput.text != "" && lastNameInput.text != "" {
            info?.name = nameInput.text
            info?.lastName = lastNameInput.text
            info?.birth = birthInput.text
            info?.occupation = occupationInput.text
            info?.country = countryInput.text
            
            
            try? info?.managedObjectContext?.save()
        }
    
        navigationController?.popViewController(animated: true)
        birthInput.text = ""; occupationInput.text = ""; nameInput.text = ""; lastNameInput.text = ""; countryInput.text = ""
    }
    
    @objc func checkError(textField: UITextField) {
         if textField == nameInput {
             for t in textField.text! {
                 if t.isNumber {
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
extension MakeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
