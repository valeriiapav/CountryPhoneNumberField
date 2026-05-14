//
//  CountryPhoneNumberField.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import UIKit

// MARK: - CountryPhoneNumberField

public final class CountryPhoneNumberField: UIView {

    // MARK: - Public API

    /// Called whenever the selected country changes.
    public var didChangeCountry: ((CPNCountry) -> Void)?
    /// Called after every keystroke with the current validation state.
    public var didValidatePhone: ((Bool) -> Void)?

    public private(set) var selectedCountry: CPNCountry?
    public private(set) var isValid: Bool = false

    /// Raw national digits in the phone field (spaces / dashes stripped).
    public var rawDigits: String {
        (phoneTextField.text ?? "").filter { $0.isNumber }
    }

    /// E.164 form (e.g. "+380671234567"), or nil when the number isn't valid yet.
    public var e164PhoneNumber: String? {
        guard let selectedCountry else { return nil }
        return validator.formatE164(rawDigits, regionCode: selectedCountry.code)
    }

    // MARK: - Private — services

    private let configuration: CountryPhoneNumberFieldConfiguration
    private let validator    = PhoneNumberValidator()
    private let repository   = CPNCountryRepository()
    private let formatter    = PhoneAsYouTypeFormatter()

    // MARK: - Private — views

    private let countryButton  = UIButton(type: .system)
    private let phoneTextField = UITextField()
    private let separator      = UIView()

    // MARK: - Init

    public init(configuration: CountryPhoneNumberFieldConfiguration = .init()) {
        self.configuration = configuration
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        self.configuration = .init()
        super.init(coder: coder)
        setup()
    }

    // MARK: - Adaptive border colour (dark / light mode)

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.separator.cgColor
    }
}

// MARK: - One-time setup

private extension CountryPhoneNumberField {

    func setup() {
        setupContainer()
        setupCountryButton()
        setupPhoneTextField()
        buildLayout()
        selectDefaultCountry()
    }

    // ── Container ────────────────────────────────────────────────────────────

    func setupContainer() {
        backgroundColor    = .systemBackground
        layer.cornerRadius = 14
        layer.borderWidth  = 1
        layer.borderColor  = UIColor.separator.cgColor
        clipsToBounds      = true
    }

    // ── Country button ───────────────────────────────────────────────────────

    func setupCountryButton() {
        countryButton.contentHorizontalAlignment = .leading
        countryButton.addTarget(self, action: #selector(didTapCountry), for: .touchUpInside)
    }

    // ── Phone text field ─────────────────────────────────────────────────────

    func setupPhoneTextField() {
        phoneTextField.placeholder            = configuration.phonePlaceholder
        phoneTextField.keyboardType           = .numberPad
        phoneTextField.font                   = .systemFont(ofSize: 17)
        phoneTextField.textColor              = .label
        phoneTextField.autocorrectionType     = .no
        phoneTextField.autocapitalizationType = .none
        phoneTextField.smartInsertDeleteType  = .no
        phoneTextField.delegate               = self
    }

    // ── Layout ───────────────────────────────────────────────────────────────

    func buildLayout() {
        // Country column: label + button
        let countryLabel      = UILabel()
        countryLabel.text     = configuration.countryTitle
        countryLabel.font     = .systemFont(ofSize: 13)
        countryLabel.textColor = .secondaryLabel

        let countryStack       = UIStackView(arrangedSubviews: [countryLabel, countryButton])
        countryStack.axis      = .vertical
        countryStack.spacing   = 6
        countryStack.alignment = .leading

        // Phone column: label + text field
        let phoneLabel        = UILabel()
        phoneLabel.text       = configuration.phoneTitle
        phoneLabel.font       = .systemFont(ofSize: 13)
        phoneLabel.textColor  = .secondaryLabel

        let phoneStack       = UIStackView(arrangedSubviews: [phoneLabel, phoneTextField])
        phoneStack.axis      = .vertical
        phoneStack.spacing   = 6

        // Separator view
        separator.backgroundColor = .separator

        [countryStack, separator, phoneStack].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Country column — fixed width, pinned left
            countryStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            countryStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            countryStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            countryStack.widthAnchor.constraint(equalToConstant: 100),

            // Thin vertical rule
            separator.leadingAnchor.constraint(equalTo: countryStack.trailingAnchor, constant: 12),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            separator.widthAnchor.constraint(equalToConstant: 1),

            // Phone column — fills remaining space
            phoneStack.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 16),
            phoneStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            phoneStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            phoneStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    // ── Default country ──────────────────────────────────────────────────────

    func selectDefaultCountry() {
        let country =
            repository.country(forCode: configuration.defaultCountryCode)
            ?? repository.country(forCode: "UA")
            ?? repository.countries.first

        if let country { select(country, clearText: false) }
    }
}

// MARK: - Country selection

private extension CountryPhoneNumberField {

    func select(_ country: CPNCountry, clearText: Bool = true) {
        selectedCountry = country
        formatter.configure(regionCode: country.code, dialCode: country.dialCode)
        refreshCountryButton(country)

        if clearText { phoneTextField.text = nil }

        validate()
        didChangeCountry?(country)
    }

    func refreshCountryButton(_ country: CPNCountry) {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero

        // "🇺🇦  +380"
        var attrs = AttributeContainer()
        attrs.font            = UIFont.systemFont(ofSize: 17)
        attrs.foregroundColor = UIColor.label
        config.attributedTitle = AttributedString(
            "\(country.emoji)  \(country.dialCode)",
            attributes: attrs
        )

        // Small trailing chevron
        config.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        )
        config.imagePlacement      = .trailing
        config.imagePadding        = 6
        config.baseForegroundColor = .secondaryLabel

        countryButton.configuration = config
    }

    @objc func didTapCountry() {
        guard let parentVC = parentViewController else { return }
        phoneTextField.resignFirstResponder()
        showPicker(in: parentVC.view)
    }
}

// MARK: - Country picker bottom sheet

private extension CountryPhoneNumberField {

    func showPicker(in parentView: UIView) {
        let picker = CountryPickerView()
        picker.configure(countries: repository.countries, selectedCountry: selectedCountry)

        // Dimmed backdrop (tappable UIControl to dismiss)
        let backdrop = UIControl()
        backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        backdrop.alpha = 0

        // Sheet
        let sheet = UIView()
        sheet.backgroundColor     = .systemBackground
        sheet.layer.cornerRadius  = 20
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.clipsToBounds       = true

        // Drag handle pill
        let handle               = UIView()
        handle.backgroundColor   = .tertiaryLabel
        handle.layer.cornerRadius = 2.5

        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        parentView.addSubview(backdrop)
        parentView.addSubview(sheet)
        sheet.addSubview(handle)
        sheet.addSubview(doneButton)
        sheet.addSubview(picker)

        [backdrop, sheet, handle, doneButton, picker].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let sheetH: CGFloat = 280

        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: parentView.topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            backdrop.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),

            sheet.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            sheet.heightAnchor.constraint(equalToConstant: sheetH),

            handle.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            handle.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 10),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.heightAnchor.constraint(equalToConstant: 5),

            doneButton.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -20),
            doneButton.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),

            picker.leadingAnchor.constraint(equalTo: sheet.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: sheet.trailingAnchor),
            picker.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 8),
            picker.bottomAnchor.constraint(equalTo: sheet.bottomAnchor)
        ])

        // Slide-up entrance
        sheet.transform = CGAffineTransform(translationX: 0, y: sheetH)
        UIView.animate(
            withDuration: 0.32, delay: 0,
            usingSpringWithDamping: 0.88, initialSpringVelocity: 0.5
        ) {
            sheet.transform = .identity
            backdrop.alpha  = 1
        }

        // Dismiss helper
        let dismiss = {
            UIView.animate(withDuration: 0.22, animations: {
                sheet.transform = CGAffineTransform(translationX: 0, y: sheetH)
                backdrop.alpha  = 0
            }, completion: { _ in
                sheet.removeFromSuperview()
                backdrop.removeFromSuperview()
            })
        }

        // Backdrop tap → dismiss
        backdrop.addAction(UIAction { _ in dismiss() }, for: .touchUpInside)

        // Done button → dismiss
        doneButton.addAction(UIAction { _ in dismiss() }, for: .touchUpInside)

        // Country selected
        picker.didSelectCountry = { [weak self] country in
            self?.select(country)
        }
    }
}

// MARK: - Validation

private extension CountryPhoneNumberField {

    func validate() {
        guard let country = selectedCountry else {
            isValid = false
            didValidatePhone?(false)
            return
        }
        isValid = validator.isValid(rawDigits, regionCode: country.code)
        didValidatePhone?(isValid)
    }
}

// MARK: - UITextFieldDelegate  (input filtering + as-you-type formatting)

extension CountryPhoneNumberField: UITextFieldDelegate {

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        // ── Delete ──────────────────────────────────────────────────────────
        if string.isEmpty {
            let current = rawDigits
            guard !current.isEmpty else { return false }
            applyFormatting(digits: String(current.dropLast()))
            return false
        }

        // ── Accept digits only — strip everything else ───────────────────────
        // This handles both typing (single char) and paste (multi-char with
        // symbols, spaces, dashes, country-code prefix, etc.)
        let incoming = string.filter { $0.isNumber }
        guard !incoming.isEmpty else { return false }

        // ── Full-replacement paste (e.g. "+380 67 123 45 67" or "0671234567")
        let currentText = textField.text ?? ""
        let currentNS   = currentText as NSString
        let isReplacingAll = currentNS.length > 0
            && range.location == 0
            && range.length == currentNS.length

        let newDigits: String
        if isReplacingAll || (incoming.count > 4 && currentText.isEmpty) {
            // Paste of a complete / international number — strip dial-code prefix
            let dialCodeDigits = (selectedCountry?.dialCode ?? "").filter { $0.isNumber }
            if !dialCodeDigits.isEmpty, incoming.hasPrefix(dialCodeDigits) {
                newDigits = String(incoming.dropFirst(dialCodeDigits.count))
            } else {
                newDigits = incoming
            }
        } else {
            // Normal single-digit keyboard input
            newDigits = rawDigits + incoming
        }

        applyFormatting(digits: newDigits)
        return false
    }

    // MARK: Private

    private func applyFormatting(digits: String) {
        phoneTextField.text = formatter.format(digits: digits)
        validate()
    }
}
