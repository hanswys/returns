import React, { useState } from 'react';
import OrderLookupStep from './OrderLookupStep';
import SelectItemsStep from './SelectItemsStep';
import ReasonStep from './ReasonStep';
import ReturnStatus from './ReturnStatus';

const STEPS = {
  FIND_ORDER: 1,
  SELECT_ITEMS: 2,
  REASON: 3,
  CONFIRMATION: 4,
};

export default function CustomerPortal() {
  const [currentStep, setCurrentStep] = useState(STEPS.FIND_ORDER);
  const [order, setOrder] = useState(null);
  const [selectedProducts, setSelectedProducts] = useState([]);
  const [returnRequest, setReturnRequest] = useState(null);

  const handleOrderFound = (foundOrder) => {
    setOrder(foundOrder);
    setCurrentStep(STEPS.SELECT_ITEMS);
  };

  const handleItemsSelected = (products) => {
    setSelectedProducts(products);
    setCurrentStep(STEPS.REASON);
  };

  const handleReturnSubmitted = (request) => {
    setReturnRequest(request);
    setCurrentStep(STEPS.CONFIRMATION);
  };

  const handleStartOver = () => {
    setCurrentStep(STEPS.FIND_ORDER);
    setOrder(null);
    setSelectedProducts([]);
    setReturnRequest(null);
  };

  const renderStepIndicator = () => (
    <div className="flex justify-center mb-8">
      <div className="flex items-center space-x-4">
        {[
          { step: 1, label: 'Find Order' },
          { step: 2, label: 'Select Items' },
          { step: 3, label: 'Reason' },
        ].map(({ step, label }) => (
          <div key={step} className="flex items-center">
            <div
              className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${
                currentStep >= step
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-200 text-gray-600'
              }`}
            >
              {step}
            </div>
            <span className={`ml-2 text-sm ${currentStep >= step ? 'text-blue-600' : 'text-gray-500'}`}>
              {label}
            </span>
            {step < 3 && <div className="w-12 h-0.5 mx-2 bg-gray-200" />}
          </div>
        ))}
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4">
      <div className="max-w-2xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            Return Portal
          </h1>
          <p className="text-gray-600">
            Submit a return request for your order
          </p>
        </div>

        {currentStep < STEPS.CONFIRMATION && renderStepIndicator()}

        <div className="bg-white rounded-2xl shadow-xl p-8">
          {currentStep === STEPS.FIND_ORDER && (
            <OrderLookupStep onOrderFound={handleOrderFound} />
          )}

          {currentStep === STEPS.SELECT_ITEMS && order && (
            <SelectItemsStep
              order={order}
              onItemsSelected={handleItemsSelected}
              onBack={() => setCurrentStep(STEPS.FIND_ORDER)}
            />
          )}

          {currentStep === STEPS.REASON && order && (
            <ReasonStep
              order={order}
              selectedProducts={selectedProducts}
              onSubmit={handleReturnSubmitted}
              onBack={() => setCurrentStep(STEPS.SELECT_ITEMS)}
            />
          )}

          {currentStep === STEPS.CONFIRMATION && returnRequest && (
            <ReturnStatus
              returnRequest={returnRequest}
              onStartOver={handleStartOver}
            />
          )}
        </div>
      </div>
    </div>
  );
}
